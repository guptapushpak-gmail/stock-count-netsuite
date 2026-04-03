import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/models.dart';
import '../services/netsuite_api.dart';
import '../services/secure_token_store.dart';

class AppState extends ChangeNotifier {
  final api = NetSuiteApi();
  final tokenStore = SecureTokenStore();

  String _randomState([int bytes = 24]) {
    final rand = Random.secure();
    final data = List<int>.generate(bytes, (_) => rand.nextInt(256));
    return base64UrlEncode(data).replaceAll('=', '');
  }

  String? token;
  String? accountId;
  bool authenticated = false;
  bool loading = false;
  bool submitting = false;
  String? error;

  List<LocationModel> locations = [];
  final List<AdjustmentAccountModel> adjustmentAccounts = [];
  LocationModel? selectedLocation;
  final List<CountSession> sessions = [];
  final List<InventoryItemModel> catalogItems = [];
  final List<ScannedItem> scannedItems = [];

  Future<void> bootstrap() async {
    loading = true;
    error = null;
    notifyListeners();

    token = await tokenStore.readToken();
    accountId = await tokenStore.readAccountId();
    authenticated = token != null;

    if (authenticated && token != null && accountId != null && accountId!.isNotEmpty) {
      try {
        locations = await api.fetchLocations(accountId: accountId!, token: token!);
      } catch (e) {
        error = e.toString();
      }

      try {
        adjustmentAccounts
          ..clear()
          ..addAll(await api.fetchAdjustmentAccounts(accountId: accountId!, token: token!));
      } catch (_) {
        // Account list permission can vary by role; do not block app startup.
        adjustmentAccounts.clear();
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loginWithNetSuite({
    required String account,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    String? roleId,
    String? loginHint,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final cfg = NetSuiteAuthConfig(
        accountId: account,
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        roleId: roleId,
        loginHint: loginHint,
      );

      final callbackUrlScheme = Uri.parse(redirectUri).scheme;
      final oauthState = _randomState();
      final result = await FlutterWebAuth2.authenticate(
        url: cfg.buildAuthorizeUrl(state: oauthState),
        callbackUrlScheme: callbackUrlScheme,
      );

      final uri = Uri.parse(result);
      String? code = uri.queryParameters['code'];
      String? returnedState = uri.queryParameters['state'];
      String? oauthError = uri.queryParameters['error'] ?? uri.queryParameters['error_description'];

      // Some providers return values in URL fragment: #code=...&state=...
      if (((code == null || code.isEmpty) || (returnedState == null || returnedState.isEmpty)) && uri.fragment.isNotEmpty) {
        final frag = Uri.splitQueryString(uri.fragment);
        code ??= frag['code'];
        returnedState ??= frag['state'];
        oauthError ??= frag['error'] ?? frag['error_description'];
      }

      if (returnedState != oauthState) {
        throw Exception('OAuth state mismatch. Expected $oauthState, got ${returnedState ?? 'null'}. Callback: $result');
      }

      if (code == null || code.isEmpty) {
        throw Exception('No authorization code returned from NetSuite. OAuth error: ${oauthError ?? 'unknown'}. Callback: $result');
      }

      token = await api.exchangeCodeForToken(cfg: cfg, code: code);
      accountId = account;
      await tokenStore.saveToken(token!);
      await tokenStore.saveAccountId(account);

      locations = await api.fetchLocations(accountId: account, token: token!);

      try {
        adjustmentAccounts
          ..clear()
          ..addAll(await api.fetchAdjustmentAccounts(accountId: account, token: token!));
      } catch (_) {
        // Allow login even if account list API is not permitted for this role.
        adjustmentAccounts.clear();
      }

      authenticated = true;
    } catch (e) {
      authenticated = false;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> downloadDataForLocation(LocationModel location) async {
    selectedLocation = location;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final items = await api.downloadStocktakeData(
        accountId: accountId ?? '',
        token: token!,
        locationId: location.id,
      );
      catalogItems
        ..clear()
        ..addAll(items);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logoutAndClearToken() async {
    await tokenStore.clear();
    token = null;
    authenticated = false;
    locations = [];
    adjustmentAccounts.clear();
    selectedLocation = null;
    catalogItems.clear();
    scannedItems.clear();
    notifyListeners();
  }

  void addSession(CountSession session) {
    sessions.insert(0, session);
    notifyListeners();
  }

  void addScanned(String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) return;

    InventoryItemModel? matched;
    for (final item in catalogItems) {
      if (item.upc == normalized) {
        matched = item;
        break;
      }
    }

    final itemId = matched?.id ?? 'unknown:$normalized';
    final name = matched?.name ?? 'Unknown UPC $normalized';
    final upc = matched?.upc ?? normalized;

    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index >= 0) {
      scannedItems[index] = scannedItems[index].copyWith(qty: scannedItems[index].qty + 1);
    } else {
      scannedItems.add(ScannedItem(itemId: itemId, upc: upc, name: name, qty: 1));
    }
    notifyListeners();
  }

  void increaseQty(String itemId) {
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index < 0) return;
    scannedItems[index] = scannedItems[index].copyWith(qty: scannedItems[index].qty + 1);
    notifyListeners();
  }

  void decreaseQty(String itemId) {
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index < 0) return;
    final current = scannedItems[index].qty;
    if (current <= 1) {
      scannedItems.removeAt(index);
    } else {
      scannedItems[index] = scannedItems[index].copyWith(qty: current - 1);
    }
    notifyListeners();
  }

  Future<String> submitInventoryAdjustment({
    required String adjustmentAccountId,
    String? subsidiaryId,
    String? memo,
  }) async {
    if (token == null || accountId == null || selectedLocation == null) {
      throw Exception('Missing auth/location. Please login and select location first.');
    }

    submitting = true;
    error = null;
    notifyListeners();

    try {
      final countedByItem = <String, int>{};
      for (final s in scannedItems) {
        if (s.itemId.startsWith('unknown:')) continue;
        countedByItem[s.itemId] = (countedByItem[s.itemId] ?? 0) + s.qty;
      }
      if (countedByItem.isEmpty) {
        throw Exception('No matched scanned items to submit.');
      }

      final onHand = await api.fetchOnHandByItem(
        accountId: accountId!,
        token: token!,
        locationId: selectedLocation!.id,
        itemIds: countedByItem.keys.toList(growable: false),
      );

      final lines = <Map<String, dynamic>>[];
      countedByItem.forEach((itemId, countedQty) {
        final currentOnHand = onHand[itemId] ?? 0;
        final adjust = countedQty - currentOnHand;
        if (adjust != 0) {
          lines.add({'itemId': itemId, 'adjustQtyBy': adjust});
        }
      });

      if (lines.isEmpty) {
        throw Exception('No quantity difference found. Nothing to adjust.');
      }

      final adjustmentId = await api.createInventoryAdjustment(
        accountId: accountId!,
        token: token!,
        locationId: selectedLocation!.id,
        adjustmentAccountId: adjustmentAccountId,
        subsidiaryId: (subsidiaryId == null || subsidiaryId.trim().isEmpty)
            ? selectedLocation?.subsidiaryId
            : subsidiaryId,
        memo: memo,
        lines: lines,
      );

      scannedItems.clear();
      notifyListeners();
      return adjustmentId;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
