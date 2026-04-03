import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/models.dart';

class NetSuiteAuthConfig {
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  // Empty = account-agnostic flow (user selects account on NetSuite login page).
  final String accountId;

  const NetSuiteAuthConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.accountId = '',
  });

  bool get _hasAccount => accountId.isNotEmpty;

  String baseUrlForAccount(String account) =>
      'https://$account.suitetalk.api.netsuite.com';

  String buildAuthorizeUrl({String? state}) {
    final host = _hasAccount
        ? '$accountId.app.netsuite.com'
        : 'system.netsuite.com';
    final params = <String, String>{
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'rest_webservices',
      'prompt': 'login',
    };
    if (state != null && state.isNotEmpty) params['state'] = state;
    return Uri.https(host, '/app/login/oauth2/authorize.nl', params).toString();
  }

  String buildTokenEndpoint({String? account}) {
    final a = account ?? accountId;
    if (a.isNotEmpty) return 'https://$a.suitetalk.api.netsuite.com/services/rest/auth/oauth2/v1/token';
    return 'https://system.netsuite.com/services/rest/auth/oauth2/v1/token';
  }

  String basicAuthHeader() {
    final raw = '$clientId:$clientSecret';
    final enc = base64Encode(utf8.encode(raw));
    return 'Basic $enc';
  }
}

class NetSuiteApi {
  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map<String, dynamic>) {
      return (value['id'] ?? value['value'] ?? value['text'] ?? '').toString().trim();
    }
    return value.toString().trim();
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  /// Returns `(token, accountId)`.
  /// Pass [accountId] if already known from the OAuth callback URL.
  Future<({String token, String accountId})> exchangeCodeForToken({
    required NetSuiteAuthConfig cfg,
    required String code,
    String? accountId,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      final response = await dio.post(
        cfg.buildTokenEndpoint(account: accountId),
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': cfg.redirectUri,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': cfg.basicAuthHeader(),
            'Accept': 'application/json',
          },
        ),
      );

      final token = response.data['access_token']?.toString() ?? '';
      if (token.isEmpty) {
        throw Exception('NetSuite token not returned. Check account/client details.');
      }

      // NetSuite may return account_id in the token response body.
      final responseAccountId =
          (response.data['account_id'] ?? response.data['company_id'] ?? '').toString().trim();

      final resolvedAccount = responseAccountId.isNotEmpty
          ? responseAccountId
          : (accountId ?? cfg.accountId);

      return (token: token, accountId: resolvedAccount);
    } on DioException catch (e) {
      throw Exception(
        'Token exchange failed: type=${e.type}, '
        'status=${e.response?.statusCode}, '
        'url=${e.requestOptions.uri}, '
        'message=${e.message}, '
        'data=${e.response?.data}',
      );
    }
  }

  Future<List<LocationModel>> fetchLocations({required String accountId, required String token}) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://$accountId.suitetalk.api.netsuite.com'));

    try {
      // Prefer SuiteQL for names that match NetSuite UI better (fullname).
      final q = await dio.post(
        '/services/rest/query/v1/suiteql',
        data: {
          'q': 'SELECT id, name, fullname, subsidiary, BUILTIN.DF(subsidiary) subsidiaryname FROM location ORDER BY fullname',
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Prefer': 'transient',
          'Content-Type': 'application/json',
        }),
      );
      final items = (q.data['items'] as List?) ?? const [];
      if (items.isNotEmpty) {
        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => LocationModel(
                  id: (e['id'] ?? '').toString(),
                  name: ((e['fullname'] ?? e['name'] ?? '').toString()).trim(),
                  subsidiaryId: _asString(e['subsidiary']).isEmpty ? null : _asString(e['subsidiary']),
                  subsidiaryName: _asString(e['subsidiaryname']).isEmpty ? null : _asString(e['subsidiaryname']),
                ))
            .where((e) => e.id.isNotEmpty)
            .toList(growable: false);
      }

      final res = await dio.get(
        '/services/rest/record/v1/location',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final fallbackItems = (res.data['items'] as List?) ?? const [];
      return fallbackItems
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception('Fetch locations failed: HTTP ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<List<InventoryItemModel>> downloadStocktakeData({
    required String accountId,
    required String token,
    required String locationId,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://$accountId.suitetalk.api.netsuite.com'));
    final all = <InventoryItemModel>[];
    var offset = 0;
    const limit = 200;

    try {
      while (true) {
        final res = await dio.get(
          '/services/rest/record/v1/inventoryItem',
          queryParameters: {
            'limit': limit,
            'offset': offset,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        final items = (res.data['items'] as List?) ?? const [];
        all.addAll(
          items
              .whereType<Map<String, dynamic>>()
              .map(InventoryItemModel.fromJson)
              .where((e) => e.id.isNotEmpty)
              .toList(growable: false),
        );

        final hasMore = res.data['hasMore'] == true;
        if (!hasMore || items.isEmpty) break;
        offset += limit;
      }

      // Keep only items with UPC for scan-first workflow, unique by UPC.
      final byUpc = <String, InventoryItemModel>{};
      for (final item in all) {
        if (item.upc.isEmpty) continue;
        byUpc[item.upc] = item;
      }
      return byUpc.values.toList(growable: false);
    } on DioException catch (e) {
      throw Exception(
        'Download failed: status=${e.response?.statusCode}, '
        'url=${e.requestOptions.uri}, data=${e.response?.data}',
      );
    }
  }

  Future<List<AdjustmentAccountModel>> fetchAdjustmentAccounts({
    required String accountId,
    required String token,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://$accountId.suitetalk.api.netsuite.com'));
    try {
      final q = await dio.post(
        '/services/rest/query/v1/suiteql',
        data: {
          'q': "SELECT id, acctnumber, acctname FROM account WHERE isinactive = 'F' ORDER BY acctnumber",
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Prefer': 'transient',
          'Content-Type': 'application/json',
        }),
      );

      final items = (q.data['items'] as List?) ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final id = _asString(e['id']);
            final num = _asString(e['acctnumber']);
            final name = _asString(e['acctname']);
            return AdjustmentAccountModel(
              id: id,
              name: [num, name].where((v) => v.isNotEmpty).join(' - '),
            );
          })
          .where((a) => a.id.isNotEmpty)
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception('Fetch accounts failed: HTTP ${e.response?.statusCode} ${e.response?.data}');
    }
  }

  Future<Map<String, double>> fetchOnHandByItem({
    required String accountId,
    required String token,
    required String locationId,
    required List<String> itemIds,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://$accountId.suitetalk.api.netsuite.com'));
    final result = <String, double>{};
    if (itemIds.isEmpty) return result;

    // Keep SuiteQL IN clause manageable.
    const chunkSize = 200;
    for (var i = 0; i < itemIds.length; i += chunkSize) {
      final chunk = itemIds.sublist(i, min(i + chunkSize, itemIds.length));
      final ids = chunk.join(',');
      var offset = 0;
      const limit = 1000;

      while (true) {
        final resp = await dio.post(
          '/services/rest/query/v1/suiteql',
          queryParameters: {'limit': limit, 'offset': offset},
          data: {
            'q': 'SELECT item, location, quantityonhand FROM InventoryBalance '
                'WHERE location = $locationId AND item IN ($ids)',
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Prefer': 'transient',
            'Content-Type': 'application/json',
          }),
        );

        final items = (resp.data['items'] as List?) ?? const [];
        for (final row in items.whereType<Map<String, dynamic>>()) {
          final itemId = _asString(row['item']);
          if (itemId.isEmpty) continue;
          final qty = _asDouble(row['quantityonhand']);
          result[itemId] = (result[itemId] ?? 0) + qty;
        }

        final hasMore = resp.data['hasMore'] == true;
        if (!hasMore || items.isEmpty) break;
        offset += limit;
      }
    }
    return result;
  }

  Future<String> createInventoryAdjustment({
    required String accountId,
    required String token,
    required String locationId,
    required String adjustmentAccountId,
    String? subsidiaryId,
    String? memo,
    required List<Map<String, dynamic>> lines,
  }) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://$accountId.suitetalk.api.netsuite.com'));

    final payload = <String, dynamic>{
      'account': {'id': adjustmentAccountId},
      'memo': (memo == null || memo.trim().isEmpty)
          ? 'Stock count adjustment from mobile app'
          : memo.trim(),
      'inventory': {
        'items': lines
            .map((l) => {
                  'item': {'id': l['itemId'].toString()},
                  'location': {'id': locationId},
                  'adjustQtyBy': l['adjustQtyBy'],
                })
            .toList(growable: false),
      },
    };

    if (subsidiaryId != null && subsidiaryId.trim().isNotEmpty) {
      payload['subsidiary'] = {'id': subsidiaryId.trim()};
    }

    try {
      final res = await dio.post(
        '/services/rest/record/v1/inventoryAdjustment',
        data: payload,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        }),
      );

      final id = _asString(res.data is Map<String, dynamic> ? res.data['id'] : null);
      if (id.isNotEmpty) return id;

      final locationHeader = _asString(res.headers.value('location'));
      if (locationHeader.isNotEmpty) {
        final m = RegExp(r'/inventoryAdjustment/(\d+)').firstMatch(locationHeader);
        if (m != null) return m.group(1)!;
      }

      return 'created';
    } on DioException catch (e) {
      throw Exception(
        'Inventory adjustment failed: status=${e.response?.statusCode}, '
        'url=${e.requestOptions.uri}, data=${e.response?.data}',
      );
    }
  }

  Future<void> syncPendingChanges({required String accountId, required String token}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// Fetches the company logo from NetSuite.
  /// Tries SuiteQL first, then falls back to the companyInformation REST record.
  /// Returns raw image bytes, or null if no logo is set / accessible.
  Future<Uint8List?> fetchCompanyLogo({required String accountId, required String token}) async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://$accountId.suitetalk.api.netsuite.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    final headers = {'Authorization': 'Bearer $token'};

    String? logoFileId;

    // Strategy 1: subsidiary REST record list → first record → logo field.
    try {
      final listResp = await dio.get(
        '/services/rest/record/v1/subsidiary',
        queryParameters: {'limit': 1},
        options: Options(headers: headers),
      );
      final items = (listResp.data['items'] as List?) ?? [];
      if (items.isNotEmpty) {
        final link = _asString((items.first as Map<String, dynamic>)['links']
            ?.firstWhere((l) => l['rel'] == 'self', orElse: () => null)?['href'] ?? '');
        final subId = link.isNotEmpty ? link.split('/').last : _asString((items.first as Map<String, dynamic>)['id']);
        debugPrint('[LOGO] subsidiary id=$subId');
        if (subId.isNotEmpty) {
          final subResp = await dio.get(
            '/services/rest/record/v1/subsidiary/$subId',
            options: Options(headers: headers),
          );
          final d = subResp.data as Map<String, dynamic>? ?? {};
          // logo field may be a nested object {id, refName} or a plain id string.
          final logoVal = d['logo'] ?? d['logoimage'];
          if (logoVal is Map) {
            logoFileId = _asString(logoVal['id']);
          } else if (logoVal != null) {
            logoFileId = _asString(logoVal);
          }
          debugPrint('[LOGO] subsidiary/$subId logo field=$logoVal → fileId=$logoFileId');
        }
      }
    } catch (e) {
      final de = e is DioException ? '${e.response?.statusCode} ${e.response?.data}' : e.toString();
      debugPrint('[LOGO] subsidiary REST strategy failed: $de');
    }

    // Strategy 2: companyInformation REST record.
    if (logoFileId == null || logoFileId.isEmpty) {
      for (final recType in ['companyInformation', 'companyinformation', 'companyPreferences']) {
        if (logoFileId != null && logoFileId!.isNotEmpty) break;
        try {
          final resp = await dio.get(
            '/services/rest/record/v1/$recType',
            options: Options(headers: headers),
          );
          final d = resp.data as Map<String, dynamic>? ?? {};
          final logoVal = d['logo'] ?? d['logoimage'] ?? d['logoUrl'];
          if (logoVal is Map) {
            logoFileId = _asString(logoVal['id']);
          } else if (logoVal != null) {
            logoFileId = _asString(logoVal);
          }
          debugPrint('[LOGO] $recType → fileId=$logoFileId');
        } catch (e) {
          final de = e is DioException ? '${e.response?.statusCode} ${e.response?.data}' : e.toString();
          debugPrint('[LOGO] $recType failed: $de');
        }
      }
    }

    if (logoFileId == null || logoFileId.isEmpty) return null;

    // Try to download the file. NetSuite may serve binary directly at /file/{id}
    // or expose a `url` in the metadata, or use a /content sub-resource.
    // Try multiple strategies in order.
    for (final path in [
      '/services/rest/record/v1/file/$logoFileId/content',
      '/services/rest/record/v1/file/$logoFileId',
    ]) {
      try {
        final resp = await dio.get(
          path,
          options: Options(
            headers: {...headers, 'Accept': '*/*'},
            responseType: ResponseType.bytes,
            followRedirects: true,
          ),
        );
        debugPrint('[LOGO] $path → contentType=${resp.headers.value('content-type')}, len=${resp.data?.length}');
        final data = resp.data;
        if (data is List<int> && data.isNotEmpty) return Uint8List.fromList(data);
        if (data is Uint8List && data.isNotEmpty) return data;
      } catch (e) {
        final de = e is DioException ? '${e.response?.statusCode} ${e.response?.data?.toString().substring(0, (e.response?.data?.toString().length ?? 0).clamp(0, 200))}' : e.toString();
        debugPrint('[LOGO] $path failed: $de');
      }
    }

    // If binary fetch failed, try to get metadata and follow the URL.
    try {
      final meta = await dio.get(
        '/services/rest/record/v1/file/$logoFileId',
        options: Options(headers: headers),
      );
      final d = meta.data as Map<String, dynamic>? ?? {};
      debugPrint('[LOGO] file/$logoFileId metadata keys=${d.keys.toList()}');
      final url = _asString(d['url'] ?? d['fileUrl'] ?? d['downloadUrl']);
      if (url.isNotEmpty) {
        final bytes = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (bytes.data != null && bytes.data!.isNotEmpty) {
          return Uint8List.fromList(bytes.data!);
        }
      }
    } catch (e) {
      debugPrint('[LOGO] metadata fallback failed: $e');
    }
    return null;
  }
}
