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

  // Current user info (populated after login)
  String? currentUserName;
  String? currentRoleName;
  String? currentUserEmail;

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
              .map((r) => InventoryItemModel(
                    id: r.id,
                    name: r.name,
                    upc: r.upc,
                    isLotItem: r.isLotItem,
                    isSerialItem: r.isSerialItem,
                  ))
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
              .map((r) => ScannedItem(
                    itemId: r.itemId,
                    upc: r.upc,
                    name: r.name,
                    qty: r.qty,
                    isLotItem: r.isLotItem,
                    isSerialItem: r.isSerialItem,
                    lotSerialAssignments: ScannedItem.decodeLotSerial(r.lotSerialData),
                  ))
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

    // Silently refresh catalog items for the selected location so that
    // isLotItem / isSerialItem flags are always up to date (handles DB rows
    // that were cached before schema v2 added those columns).
    if (selectedLocation != null) {
      api.downloadStocktakeData(
        accountId: accountId!,
        token: token!,
        locationId: selectedLocation!.id,
      ).then((fresh) async {
        catalogItems = fresh;
        // Also propagate fresh lot/serial flags to any already-scanned items
        // so the scan page UI reflects the correct state immediately.
        final freshById = {for (final f in fresh) f.id: f};
        for (var i = 0; i < scannedItems.length; i++) {
          final s = scannedItems[i];
          if (s.itemId.startsWith('unknown:')) continue;
          final cat = freshById[s.itemId];
          if (cat == null) continue;
          if ((cat.isLotItem || cat.isSerialItem) != (s.isLotItem || s.isSerialItem)) {
            scannedItems[i] = ScannedItem(
              itemId: s.itemId,
              upc: s.upc,
              name: s.name,
              qty: s.qty,
              isLotItem: cat.isLotItem,
              isSerialItem: cat.isSerialItem,
              lotSerialAssignments: s.lotSerialAssignments,
            );
          }
        }
        await db.replaceItemsForLocation(
          selectedLocation!.id,
          fresh.map((i) => CatalogItemsCompanion.insert(
                id: i.id,
                locationId: selectedLocation!.id,
                name: i.name,
                upc: i.upc,
                isLotItem: Value(i.isLotItem),
                isSerialItem: Value(i.isSerialItem),
              )).toList(),
        );
        notifyListeners();
        debugPrint('[REFRESH] Catalog refreshed: ${fresh.length} items');
      }).catchError((e) {
        debugPrint('[REFRESH] Catalog refresh failed (non-fatal): $e');
      });
    }

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
      final callbackEntityId = uri.queryParameters['entity'];
      final callbackRoleId = uri.queryParameters['role'];
      debugPrint('[AUTH] callbackAccountId: $callbackAccountId, entity: $callbackEntityId, role: $callbackRoleId');

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

      // Fetch user & role display names in background (non-fatal).
      if (callbackEntityId != null || callbackRoleId != null) {
        api.fetchUserInfo(
          accountId: accountId!,
          token: token!,
          entityId: callbackEntityId,
          roleId: callbackRoleId,
        ).then((info) {
          currentUserName = info.name;
          currentRoleName = info.roleName;
          currentUserEmail = info.email;
          notifyListeners();
        }).catchError((e) { debugPrint('[AUTH] user info fetch failed: $e'); });
      }

      // Refresh catalog flags in background after fresh login so that any
      // stale isLotItem/isSerialItem values in scanned items are corrected.
      _refreshCachedData();
    } catch (e, st) {
      debugPrint('[AUTH] ERROR: $e\n$st');
      authenticated = false;
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ── Auth helpers ─────────────────────────────────────────────────────────

  /// Returns true if [e] looks like a 401/403 (expired or invalid token).
  static bool isAuthError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('401') || msg.contains('403') ||
        msg.contains('unauthorized') || msg.contains('invalid_token') ||
        msg.contains('expired') || msg.contains('token');
  }

  /// Clears auth state so the router redirects to the login page.
  Future<void> expireSession() async {
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
    currentUserName = null;
    currentRoleName = null;
    currentUserEmail = null;
    error = 'Session expired. Please sign in again.';
    notifyListeners();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  /// Sync all data required for stocktaking at [location].
  ///
  /// The [onStep] callback fires whenever a step transitions:
  ///   stepIndex  0 = Inventory Items, 1 = Adjustment Accounts, 2 = Saving to device
  ///   active     true while the step is in progress, false when it finishes
  ///   detail     human-readable status string
  Future<void> syncDataForLocation(
    LocationModel location, {
    void Function(int stepIndex, bool active, String detail)? onStep,
  }) async {
    selectedLocation = location;
    db.setSelectedLocation(location.id);
    error = null;

    try {
      // ── Step 0: Inventory Items ──────────────────────────────────────────
      onStep?.call(0, true, 'Connecting…');
      late final List<InventoryItemModel> items;
      try {
        items = await api.downloadStocktakeData(
          accountId: accountId ?? '',
          token: token!,
          locationId: location.id,
          onProgress: (n) => onStep?.call(0, true, '$n items fetched'),
        );
      } catch (e) {
        if (isAuthError(e)) {
          await expireSession();
          throw Exception('Session expired. Please sign in again.');
        }
        rethrow;
      }
      onStep?.call(0, false, '${items.length} items downloaded');

      // ── Step 1: Adjustment Accounts ──────────────────────────────────────
      onStep?.call(1, true, 'Fetching accounts…');
      List<AdjustmentAccountModel> accts = [];
      try {
        accts = await api.fetchAdjustmentAccounts(
          accountId: accountId!,
          token: token!,
        );
        adjustmentAccounts
          ..clear()
          ..addAll(accts);
        debugPrint('[SYNC] Accounts fetched: ${accts.length}');
      } catch (e) {
        // Fall back to cached accounts — do not block the sync.
        accts = List.of(adjustmentAccounts);
        debugPrint('[SYNC] Accounts fetch failed (using cache): $e');
      }
      onStep?.call(1, false, '${accts.length} accounts synced');

      // ── Step 2: Save to local database ───────────────────────────────────
      onStep?.call(2, true, 'Writing to local database…');
      catalogItems = items;
      await Future.wait([
        db.replaceItemsForLocation(
          location.id,
          items
              .map((i) => CatalogItemsCompanion.insert(
                    id: i.id,
                    locationId: location.id,
                    name: i.name,
                    upc: i.upc,
                    isLotItem: Value(i.isLotItem),
                    isSerialItem: Value(i.isSerialItem),
                  ))
              .toList(),
        ),
        db.replaceAccounts(
          accts
              .map((a) => AdjustmentAccountsCompanion.insert(id: a.id, name: a.name))
              .toList(),
        ),
      ]);
      onStep?.call(2, false, 'All data saved locally');
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Keep the old method as a thin wrapper for any callers that don't need progress.
  Future<void> downloadDataForLocation(LocationModel location) =>
      syncDataForLocation(location);

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
    currentUserName = null;
    currentRoleName = null;
    currentUserEmail = null;
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

  /// Add a scanned barcode — looks up by UPC in the catalog.
  void addScanned(String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) return;

    InventoryItemModel? matched;
    for (final item in catalogItems) {
      if (item.upc.isNotEmpty && item.upc == normalized) {
        matched = item;
        break;
      }
    }

    final itemId = matched?.id ?? 'unknown:$normalized';
    final name = matched?.name ?? 'Unknown barcode: $normalized';
    final upc = matched?.upc ?? normalized;
    final isLot = matched?.isLotItem ?? false;
    final isSerial = matched?.isSerialItem ?? false;

    int newQty;
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index >= 0) {
      // For lot/serial items scanned by barcode, just increment the qty counter
      // so the user can see it was scanned. They must add lot detail before submit.
      newQty = scannedItems[index].qty + 1;
      scannedItems[index] = scannedItems[index].copyWith(qty: newQty);
    } else {
      newQty = 1;
      scannedItems.add(ScannedItem(
        itemId: itemId,
        upc: upc,
        name: name,
        qty: newQty,
        isLotItem: isLot,
        isSerialItem: isSerial,
      ));
    }

    if (activeSessionId != null) {
      final si = scannedItems[scannedItems.indexWhere((e) => e.itemId == itemId)];
      db.upsertScannedItem(
        sessionId: activeSessionId!,
        itemId: itemId,
        upc: upc,
        name: name,
        qty: newQty,
        isLotItem: isLot,
        isSerialItem: isSerial,
        lotSerialData: ScannedItem.encodeLotSerial(si.lotSerialAssignments),
      );
    }
    notifyListeners();
  }

  /// Returns the catalog item matching [upc], or null if not found.
  InventoryItemModel? findItemByBarcode(String upc) {
    final normalized = upc.trim();
    for (final item in catalogItems) {
      if (item.upc.isNotEmpty && item.upc == normalized) return item;
    }
    return null;
  }

  /// Add a catalog item directly by ID (used from search results).
  /// For lot/serial items, pass [lotSerialAssignments] to record detail.
  void addCatalogItem(InventoryItemModel item,
      {List<LotSerialAssignment>? lotSerialAssignments}) {
    final assignments = lotSerialAssignments ?? const [];
    final index = scannedItems.indexWhere((e) => e.itemId == item.id);
    final int newQty;

    if (index >= 0) {
      if (item.isLotItem || item.isSerialItem) {
        // Merge new assignments into existing ones
        final merged = [
          ...scannedItems[index].lotSerialAssignments,
          ...assignments,
        ];
        newQty = merged.fold(0, (s, a) => s + a.qty);
        scannedItems[index] =
            scannedItems[index].copyWith(qty: newQty, lotSerialAssignments: merged);
      } else {
        newQty = scannedItems[index].qty + 1;
        scannedItems[index] = scannedItems[index].copyWith(qty: newQty);
      }
    } else {
      newQty = assignments.isNotEmpty
          ? assignments.fold(0, (s, a) => s + a.qty)
          : 1;
      scannedItems.add(ScannedItem(
        itemId: item.id,
        upc: item.upc,
        name: item.name,
        qty: newQty,
        isLotItem: item.isLotItem,
        isSerialItem: item.isSerialItem,
        lotSerialAssignments: assignments,
      ));
    }

    if (activeSessionId != null) {
      final si = scannedItems[scannedItems.indexWhere((e) => e.itemId == item.id)];
      db.upsertScannedItem(
        sessionId: activeSessionId!,
        itemId: item.id,
        upc: item.upc,
        name: item.name,
        qty: newQty,
        isLotItem: item.isLotItem,
        isSerialItem: item.isSerialItem,
        lotSerialData: ScannedItem.encodeLotSerial(si.lotSerialAssignments),
      );
    }
    notifyListeners();
  }

  /// Update the lot/serial assignments for an already-scanned item.
  void updateLotSerial(String itemId, List<LotSerialAssignment> assignments) {
    final index = scannedItems.indexWhere((e) => e.itemId == itemId);
    if (index < 0) return;
    final newQty = assignments.fold(0, (s, a) => s + a.qty);
    scannedItems[index] =
        scannedItems[index].copyWith(qty: newQty, lotSerialAssignments: assignments);
    if (activeSessionId != null) {
      final si = scannedItems[index];
      db.upsertScannedItem(
        sessionId: activeSessionId!,
        itemId: si.itemId,
        upc: si.upc,
        name: si.name,
        qty: newQty,
        isLotItem: si.isLotItem,
        isSerialItem: si.isSerialItem,
        lotSerialData: ScannedItem.encodeLotSerial(assignments),
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
      // Fetch fresh lot/serial flags from NetSuite for the items being submitted.
      // This guards against stale DB records (e.g. cached before schema v2).
      final knownIds = scannedItems
          .where((s) => !s.itemId.startsWith('unknown:'))
          .map((s) => s.itemId)
          .toSet()
          .toList();
      if (knownIds.isNotEmpty) {
        try {
          final ids = knownIds.join(',');
          debugPrint('[SUBMIT] Fetching lot/serial flags for ids: $ids');
          final freshItems = await api.fetchLotSerialFlags(
            accountId: accountId!,
            token: token!,
            itemIds: ids,
          );
          debugPrint('[SUBMIT] lot/serial flags result: $freshItems');
          final flagsById = {for (final f in freshItems) f.$1: (isLot: f.$2, isSerial: f.$3)};
          for (var i = 0; i < scannedItems.length; i++) {
            final s = scannedItems[i];
            if (s.itemId.startsWith('unknown:')) continue;
            final flags = flagsById[s.itemId];
            debugPrint('[SUBMIT] item ${s.itemId} flags=$flags, current isLot=${s.isLotItem} isSerial=${s.isSerialItem}');
            if (flags == null) continue;
            if ((flags.isLot || flags.isSerial) && !(s.isLotItem || s.isSerialItem)) {
              scannedItems[i] = ScannedItem(
                itemId: s.itemId,
                upc: s.upc,
                name: s.name,
                qty: s.qty,
                isLotItem: flags.isLot,
                isSerialItem: flags.isSerial,
                lotSerialAssignments: s.lotSerialAssignments,
              );
              // Also update catalog in memory
              for (var j = 0; j < catalogItems.length; j++) {
                if (catalogItems[j].id == s.itemId) {
                  catalogItems[j] = InventoryItemModel(
                    id: catalogItems[j].id,
                    name: catalogItems[j].name,
                    upc: catalogItems[j].upc,
                    isLotItem: flags.isLot,
                    isSerialItem: flags.isSerial,
                  );
                  break;
                }
              }
            }
          }
        } catch (e) {
          debugPrint('[SUBMIT] lot/serial flag refresh failed (non-fatal): $e');
        }
      }

      // Validate lot/serial items have assignments
      final lotSerialMissing = scannedItems
          .where((s) =>
              !s.itemId.startsWith('unknown:') && s.needsLotSerialDetail)
          .map((s) => s.name)
          .toList();
      if (lotSerialMissing.isNotEmpty) {
        throw Exception(
          'The following lot/serial items need lot or serial numbers before submitting:\n\n'
          '• ${lotSerialMissing.join('\n• ')}\n\n'
          'Tap each item in the list to enter lot/serial detail.',
        );
      }

      final countedByItem = <String, int>{};
      for (final s in scannedItems) {
        if (s.itemId.startsWith('unknown:')) continue;
        countedByItem[s.itemId] = (countedByItem[s.itemId] ?? 0) + s.qty;
      }
      final unmatchedCount = scannedItems.where((s) => s.itemId.startsWith('unknown:')).length;
      debugPrint('[SUBMIT] Items to submit: ${countedByItem.length}, unmatched: $unmatchedCount, scanned total: ${scannedItems.length}');
      if (countedByItem.isEmpty) {
        throw Exception(
          unmatchedCount > 0
              ? 'None of the $unmatchedCount scanned item(s) could be matched to NetSuite inventory.\n\n'
                'Tip: Use the Search field to find items by name — this works even when barcodes are not set up.'
              : 'No items to submit.',
        );
      }
      if (unmatchedCount > 0) {
        debugPrint('[SUBMIT] Warning: $unmatchedCount unmatched items will be skipped.');
      }

      debugPrint('[SUBMIT] Fetching on-hand for ${countedByItem.keys.take(5)}…');
      late final Map<String, double> onHand;
      try {
        onHand = await api.fetchOnHandByItem(
          accountId: accountId!,
          token: token!,
          locationId: selectedLocation!.id,
          itemIds: countedByItem.keys.toList(growable: false),
        );
      } catch (e) {
        debugPrint('[SUBMIT] on-hand fetch error: $e');
        if (isAuthError(e)) {
          await expireSession();
          throw Exception('Session expired. Please sign in again.');
        }
        rethrow;
      }

      final lines = <Map<String, dynamic>>[];
      final skippedNoBalance = <String>[];

      countedByItem.forEach((id, countedQty) {
        final currentQty = onHand[id]; // null = no InventoryBalance record
        if (currentQty == null) {
          // No balance record means item has 0 on-hand with prior history.
          // NetSuite rejects adjusting these ("Revaluation is no longer first transaction").
          // Skip and warn.
          final name = scannedItems.firstWhere((s) => s.itemId == id,
              orElse: () => ScannedItem(itemId: id, upc: '', name: id, qty: 0)).name;
          skippedNoBalance.add(name);
          debugPrint('[SUBMIT] Skipping $id ($name) — no on-hand balance record');
        } else {
          final adjust = countedQty - currentQty.toInt();
          if (adjust != 0) {
            final scannedEntry = scannedItems.firstWhere(
              (s) => s.itemId == id,
              orElse: () => ScannedItem(itemId: id, upc: '', name: id, qty: 0),
            );
            final line = <String, dynamic>{'itemId': id, 'adjustQtyBy': adjust};
            if (scannedEntry.lotSerialAssignments.isNotEmpty) {
              line['lotSerialAssignments'] = scannedEntry.lotSerialAssignments
                  .map((a) => {'number': a.number, 'qty': a.qty})
                  .toList();
              line['isSerialItem'] = scannedEntry.isSerialItem;
            }
            lines.add(line);
          }
        }
      });

      debugPrint('[SUBMIT] On-hand result: $onHand');
      debugPrint('[SUBMIT] Adjustment lines: $lines, skipped: $skippedNoBalance');

      if (lines.isEmpty && skippedNoBalance.isNotEmpty) {
        throw Exception(
          'Could not adjust the following items — they have no current stock at this location '
          'and cannot be adjusted via inventory adjustment:\n\n'
          '• ${skippedNoBalance.join('\n• ')}\n\n'
          'These items may need to be received first via a Purchase Order.',
        );
      }
      if (lines.isEmpty) {
        throw Exception('Quantities match current on-hand. Nothing to adjust.');
      }

      debugPrint('[SUBMIT] Creating adjustment: account=$adjustmentAccountId, subsidiary=$subsidiaryId, lines=${lines.length}');
      late final String adjustmentId;
      try {
        adjustmentId = await api.createInventoryAdjustment(
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
      } catch (e) {
        debugPrint('[SUBMIT] createInventoryAdjustment error: $e');
        if (isAuthError(e)) {
          await expireSession();
          throw Exception('Session expired. Please sign in again.');
        }
        // NetSuite returns this when a lot/serial item is submitted without
        // inventoryDetail. This can happen when the local catalog was cached
        // before isLotItem/isSerialItem flags were stored (old DB schema).
        final msg = e.toString();
        if (msg.contains('configure the inventory detail') ||
            msg.contains('inventory detail')) {
          throw Exception(
            'One or more items require lot or serial number detail before they can be adjusted.\n\n'
            'Please:\n'
            '1. Sync this location again (to refresh item types)\n'
            '2. Re-add those items — a lot/serial dialog will appear\n'
            '3. Enter the lot or serial numbers, then submit again.',
          );
        }
        rethrow;
      }

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
