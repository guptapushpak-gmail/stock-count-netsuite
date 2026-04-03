import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../models/models.dart';

class NetSuiteAuthConfig {
  final String accountId;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String? roleId;
  final String? loginHint;

  const NetSuiteAuthConfig({
    required this.accountId,
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    this.roleId,
    this.loginHint,
  });

  String get baseUrl => 'https://$accountId.suitetalk.api.netsuite.com';

  String buildAuthorizeUrl({String? state}) {
    final params = <String, String>{
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'rest_webservices',
      'prompt': 'login',
    };
    if (state != null && state.isNotEmpty) {
      params['state'] = state;
    }
    if (roleId != null && roleId!.isNotEmpty) {
      params['role'] = roleId!;
    }
    if (loginHint != null && loginHint!.isNotEmpty) {
      params['login_hint'] = loginHint!;
    }
    final uri = Uri.https('$accountId.app.netsuite.com', '/app/login/oauth2/authorize.nl', params);
    return uri.toString();
  }

  String buildTokenEndpoint() => '$baseUrl/services/rest/auth/oauth2/v1/token';

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

  Future<String> exchangeCodeForToken({
    required NetSuiteAuthConfig cfg,
    required String code,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: cfg.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      final response = await dio.post(
        '/services/rest/auth/oauth2/v1/token',
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

      final token = response.data['access_token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception('NetSuite token not returned. Check account/client details.');
      }
      return token;
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
}
