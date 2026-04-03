import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/models.dart';
import '../services/app_database.dart';
import '../services/netsuite_api.dart';

const kNetSuiteClientId = '01660c019fe6f6a4fc3a21fdabb7b1195018f4d9587b201a17aad9663b94b9b3';
const kNetSuiteClientSecret = '76b91568d6379c70c4ca80040e3fc749279994792905f6ec6e8bd980da52d0a2';
const kNetSuiteRedirectUri = 'stockcount://callback';

class AppState extends ChangeNotifier {
  final AppDatabase db;
  final api = NetSuiteApi();

  AppState(this.db);

  String? token;
  String? accountId;
  bool authenticated = false;
  bool loading = false;
  bool submitting = false;
  String? error;

  Uint8List? companyLogo;
  List<LocationModel> locations = [];
  final List<AdjustmentAccountModel> adjustmentAccounts = [];
  LocationModel? selectedLocation;
  List<CountSession> sessions = [];
  List<InventoryItemModel> catalogItems = [];
  List<ScannedItem> scannedItems = [];
  String? activeSessionId;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _extractAccountFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;
      final direct = (claims['account_id'] ?? claims['company_id'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;
      final iss = claims['iss']?.toString() ?? '';
      final m = RegExp(r'https://([^.]+)\.suitetalk\.api\.netsuite\.com').firstMatch(iss);
      return m?.group(1)?.toUpperCase();
    } catch (_) {
      return null;
    }
  }

  String _randomState([int bytes = 24]) {
    final rand = Random.secure();
    final data = List<int>.generate(bytes, (_) => rand.nextInt(256));
    return base64UrlEncode(data).replaceAll('=', '');
  }

  // ── Bootstrap ─────────────────────────────────────────────────────────────

  Future<void> bootstrap() async {
    loading = true;
    error = null;
    notifyListeners();

    final auth = await db.getAuth();
    token = auth?.token;
    accountId = auth?.accountId;
    authenticated = token != null &&
        token!.isNotEmpty &&
        accountId != null &&
        accountId!.isNotEmpty;
    companyLogo = auth?.companyLogo;

    debugPrint('[BOOT] token=${token != null ? 'present' : 'null'}, accountId=$accountId, authenticated=$authenticated');

    if (authenticated) {
      // Load cached data from DB
      final dbLocs = await db.getAllLocations();
      locations = dbLocs
          .map((r) => LocationModel(
                id: r.id,
                name: r.name,
                subsidiaryId: r.subsidiaryId,
                subsidiaryName: r.subsidiaryName,
              ))
          .toList();
      debugPrint('[BOOT] Locations loaded from DB: ${locations.length}');

      final dbAccounts = await db.getAllAccounts();
      adjustmentAccounts
        ..clear()
        ..addAll(dbAccounts.map((r) => AdjustmentAccountModel(id: r.id, name: r.name)));

      // Restore selected location
      final selLocId = auth?.selectedLocationId;
      if (selLocId != null && selLocId.isNotEmpty) {
        for (final loc in locations) {
          if (loc.id == selLocId) {
            selectedLocation = loc;
            break;
          }
        }
        if (selectedLocation != null) {
          final dbItems = await db.getItemsForLocation(selLocId);
          catalogItems = dbItems
              .map((r) => InventoryItemModel(id: r.id, name: r.name, upc: r.upc))
              .toList();
          debugPrint('[BOOT] Catalog items loaded from DB: ${catalogItems.length}');
        }
      }

      // Load sessions
      final dbSessions = await db.getAllSessions();
      sessions = dbSessions
          .map((r) => CountSession(
                id: r.id,
                locationId: r.locationId,
                locationName: r.locationName,
                status: r.status,
                createdAt: r.createdAt,
              ))
          .toList();

      // Restore active session (last in_progress)
      for (final s in sessions) {
        if (s.status == 'in_progress') {
          activeSessionId = s.id;
          final dbScanned = await db.getScannedItems(s.id);
          scannedItems = dbScanned
              .map((r) => ScannedItem(itemId: r.itemId, upc: r.upc, name: r.name, qty: r.qty))
              .toList();
          break;
        }
      }

      // Refresh from network in background
      _refreshCachedData();
    }

    loading = false;
    notifyListeners();
  }

  void _refreshCachedData() {
    if (token == null || accountId == null) return;

    api.fetchLocations(accountId: accountId!, token: token!).then((fresh) async {
      locations = fresh;
      await db.replaceLocations(fresh
          .map((l) => LocationsCompanion.insert(
                id: l.id,
                name: l.name,
                subsidiaryId: Value(l.subsidiaryId),
                subsidiaryName: Value(l.subsidiaryName),
              ))
          .toList());
      // Re-validate selected location
      if (selectedLocation != null) {
        bool stillValid = false;
        for (final l in locations) {
          if (l.id == selectedLocation!.id) {
            selectedLocation = l;
            stillValid = true;
            break;
          }
        }
        if (!stillValid) {
          selectedLocation = null;
          catalogItems.clear();
          scannedItems.clear();
          activeSessionId = null;
          await db.setSelectedLocation(null);
        }
      }
      notifyListeners();
    }).catchError((_) {});

    api.fetchAdjustmentAccounts(accountId: accountId!, token: token!).then((fresh) async {
      adjustmentAccounts
        ..clear()
        ..addAll(fresh);
      await db.replaceAccounts(
          fresh.map((a) => AdjustmentAccountsCompanion.insert(id: a.id, name: a.name)).toList());
      notifyListeners();
    }).catchError((_) {});

    if (companyLogo == null) {
      api.fetchCompanyLogo(accountId: accountId!, token: token!).then((logo) async {
        if (logo != null) {
          companyLogo = logo;
          await db.setCompanyLogo(logo);
          notifyListeners();
        }
      }).catchError((_) {});
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> loginWithNetSuite() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final cfg = NetSuiteAuthConfig(
        clientId: kNetSuiteClientId,
        clientSecret: kNetSuiteClientSecret,
        redirectUri: kNetSuiteRedirectUri,
      );

      final callbackUrlScheme = Uri.parse(kNetSuiteRedirectUri).scheme;
      final oauthState = _randomState();
      final authorizeUrl = cfg.buildAuthorizeUrl(state: oauthState);
      debugPrint('[AUTH] Authorize URL: $authorizeUrl');

      final result = await FlutterWebAuth2.authenticate(
        url: authorizeUrl,
        callbackUrlScheme: callbackUrlScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: true),
      );

      debugPrint('[AUTH] Callback result: $result');
      final uri = Uri.parse(result);

      String? code = uri.queryParameters['code'];
      String? returnedState = uri.queryParameters['state'];
      String? oauthError = uri.queryParameters['error'] ?? uri.queryParameters['error_description'];

      if (((code == null || code.isEmpty) || (returnedState == null || returnedState.isEmpty)) &&
          uri.fragment.isNotEmpty) {
        final frag = Uri.splitQueryString(uri.fragment);
        code ??= frag['code'];
        returnedState ??= frag['state'];
        oauthError ??= frag['error'] ?? frag['error_description'];
      }

      if (returnedState != oauthState) {
        throw Exception('OAuth state mismatch. Expected $oauthState, got ${returnedState ?? 'null'}. Callback: $result');
      }
      if (code == null || code.isEmpty) {
        throw Exception('No authorization code returned. OAuth error: ${oauthError ?? 'unknown'}. Callback: $result');
      }

      final callbackAccountId = (uri.queryParameters['company'] ??
              uri.queryParameters['accountDomain']?.split('.').first.toUpperCase() ??
              uri.queryParameters['account_domain']?.split('.').first.toUpperCase() ??
              uri.queryParameters['accountdomain']?.split('.').first.toUpperCase())
          ?.toUpperCase();
      debugPrint('[AUTH] callbackAccountId: $callbackAccountId');

      final exchanged = await api.exchangeCodeForToken(
        cfg: cfg,
        code: code,
        accountId: callbackAccountId,
      );

      token = exchanged.token;
      accountId = exchanged.accountId.isNotEmpty ? exchanged.accountId : callbackAccountId;

      if (accountId == null || accountId!.isEmpty) {
        accountId = _extractAccountFromJwt(token!);
      }
      if (accountId == null || accountId!.isEmpty) {
        throw Exception('Could not determine NetSuite account ID after login. Callback: $result');
      }

      await db.saveAuth(token!, accountId!);

      locations = await api.fetchLocations(accountId: accountId!, token: token!);
      await db.replaceLocations(locations
          .map((l) => LocationsCompanion.insert(
                id: l.id,
                name: l.name,
                subsidiaryId: Value(l.subsidiaryId),
                subsidiaryName: Value(l.subsidiaryName),
              ))
          .toList());

      try {
        final accts = await api.fetchAdjustmentAccounts(accountId: accountId!, token: token!);
        adjustmentAccounts
          ..clear()
          ..addAll(accts);
        await db.replaceAccounts(
            accts.map((a) => AdjustmentAccountsCompanion.insert(id: a.id, name: a.name)).toList());
      } catch (e) {
        debugPrint('[AUTH] Adjustment accounts fetch failed (non-fatal): $e');
        adjustmentAccounts.clear();
      }

      final logo = await api.fetchCompanyLogo(accountId: accountId!, token: token!);
      if (logo != null) {
        companyLogo = logo;
        await db.setCompanyLogo(logo);
      }

      authenticated = true;
    } catch (e, st) {
      debugPrint('[AUTH] ERROR: $e\n$st');
      authenticated = false;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> downloadDataForLocation(LocationModel location) async {
    selectedLocation = location;
    db.setSelectedLocation(location.id);
    loading = true;
    error = null;
    notifyListeners();
    try {
      final items = await api.downloadStocktakeData(
        accountId: accountId ?? '',
        token: token!,
        locationId: location.id,
      );
      catalogItems = items;
      await db.replaceItemsForLocation(
        location.id,
        items
            .map((i) => CatalogItemsCompanion.insert(
                  id: i.id,
                  locationId: location.id,
                  name: i.name,
                  upc: i.upc,
                ))
            .toList(),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearSelectedLocation() {
    selectedLocation = null;
    catalogItems.clear();
    scannedItems.clear();
    activeSessionId = null;
    db.setSelectedLocation(null);
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logoutAndClearToken() async {
    await db.clearAuth();
    token = null;
    accountId = null;
    authenticated = false;
    companyLogo = null;
    locations = [];
    adjustmentAccounts.clear();
    selectedLocation = null;
    catalogItems.clear();
    scannedItems.clear();
    sessions.clear();
    activeSessionId = null;
    notifyListeners();
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  void addSession(CountSession session) {
    sessions.insert(0, session);
    activeSessionId = session.id;
    scannedItems.clear();
    db.insertSession(CountSessionsCompanion.insert(
      id: session.id,
      locationId: session.locationId,
      locationName: session.locationName,
      status: session.status,
      createdAt: session.createdAt,
    ));
    notifyListeners();
  }

  // ── Scanning ──────────────────────────────────────────────────────────────

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

    int newQty;
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index >= 0) {
      newQty = scannedItems[index].qty + 1;
      scannedItems[index] = scannedItems[index].copyWith(qty: newQty);
    } else {
      newQty = 1;
      scannedItems.add(ScannedItem(itemId: itemId, upc: upc, name: name, qty: newQty));
    }

    if (activeSessionId != null) {
      db.upsertScannedItem(
        sessionId: activeSessionId!,
        itemId: itemId,
        upc: upc,
        name: name,
        qty: newQty,
      );
    }
    notifyListeners();
  }

  void increaseQty(String itemId) {
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index < 0) return;
    final newQty = scannedItems[index].qty + 1;
    scannedItems[index] = scannedItems[index].copyWith(qty: newQty);
    if (activeSessionId != null) {
      final item = scannedItems[index];
      db.upsertScannedItem(
        sessionId: activeSessionId!,
        itemId: itemId,
        upc: item.upc,
        name: item.name,
        qty: newQty,
      );
    }
    notifyListeners();
  }

  void decreaseQty(String itemId) {
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index < 0) return;
    final current = scannedItems[index].qty;
    if (current <= 1) {
      scannedItems.removeAt(index);
      if (activeSessionId != null) {
        db.removeScannedItem(activeSessionId!, itemId);
      }
    } else {
      final newQty = current - 1;
      scannedItems[index] = scannedItems[index].copyWith(qty: newQty);
      if (activeSessionId != null) {
        final item = scannedItems[index];
        db.upsertScannedItem(
          sessionId: activeSessionId!,
          itemId: itemId,
          upc: item.upc,
          name: item.name,
          qty: newQty,
        );
      }
    }
    notifyListeners();
  }

  // ── Submit adjustment ─────────────────────────────────────────────────────

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
      countedByItem.forEach((id, countedQty) {
        final adjust = countedQty - (onHand[id] ?? 0);
        if (adjust != 0) lines.add({'itemId': id, 'adjustQtyBy': adjust});
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

      // Mark session completed
      if (activeSessionId != null) {
        await db.markSessionCompleted(activeSessionId!);
        await db.clearScannedItems(activeSessionId!);
        for (var i = 0; i < sessions.length; i++) {
          if (sessions[i].id == activeSessionId) {
            sessions[i] = CountSession(
              id: sessions[i].id,
              locationId: sessions[i].locationId,
              locationName: sessions[i].locationName,
              status: 'completed',
              createdAt: sessions[i].createdAt,
            );
            break;
          }
        }
        activeSessionId = null;
      }

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
