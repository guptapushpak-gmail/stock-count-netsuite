import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── Table definitions ────────────────────────────────────────────────────────

class AuthStore extends Table {
  IntColumn get id => integer()();
  TextColumn get token => text().nullable()();
  TextColumn get accountId => text().nullable()();
  TextColumn get selectedLocationId => text().nullable()();
  BlobColumn get companyLogo => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get subsidiaryId => text().nullable()();
  TextColumn get subsidiaryName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AdjustmentAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CatalogItems extends Table {
  TextColumn get id => text()();
  TextColumn get locationId => text()();
  TextColumn get name => text()();
  TextColumn get upc => text()();

  @override
  Set<Column> get primaryKey => {id, locationId};
}

class CountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get locationId => text()();
  TextColumn get locationName => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ScannedItems extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get itemId => text()();
  TextColumn get upc => text()();
  TextColumn get name => text()();
  IntColumn get qty => integer()();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  AuthStore,
  Locations,
  AdjustmentAccounts,
  CatalogItems,
  CountSessions,
  ScannedItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'stock_count.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthStoreData?> getAuth() =>
      (select(authStore)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> saveAuth(String token, String accountId) =>
      into(authStore).insertOnConflictUpdate(AuthStoreCompanion(
        id: const Value(1),
        token: Value(token),
        accountId: Value(accountId),
      ));

  Future<void> setSelectedLocation(String? locationId) async {
    await into(authStore).insertOnConflictUpdate(AuthStoreCompanion(
      id: const Value(1),
      selectedLocationId: Value(locationId),
    ));
  }

  Future<void> setCompanyLogo(Uint8List? logo) async {
    await into(authStore).insertOnConflictUpdate(AuthStoreCompanion(
      id: const Value(1),
      companyLogo: Value(logo),
    ));
  }

  Future<void> clearAuth() => delete(authStore).go();

  // ── Locations ─────────────────────────────────────────────────────────────

  Future<List<LocationsData>> getAllLocations() =>
      (select(locations)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<void> replaceLocations(List<LocationsCompanion> rows) =>
      transaction(() async {
        await delete(locations).go();
        if (rows.isNotEmpty) await batch((b) => b.insertAll(locations, rows));
      });

  // ── Adjustment accounts ────────────────────────────────────────────────────

  Future<List<AdjustmentAccountsData>> getAllAccounts() =>
      select(adjustmentAccounts).get();

  Future<void> replaceAccounts(List<AdjustmentAccountsCompanion> rows) =>
      transaction(() async {
        await delete(adjustmentAccounts).go();
        if (rows.isNotEmpty) await batch((b) => b.insertAll(adjustmentAccounts, rows));
      });

  // ── Catalog items ─────────────────────────────────────────────────────────

  Future<List<CatalogItemsData>> getItemsForLocation(String locationId) =>
      (select(catalogItems)..where((t) => t.locationId.equals(locationId))).get();

  Future<void> replaceItemsForLocation(
    String locationId,
    List<CatalogItemsCompanion> rows,
  ) =>
      transaction(() async {
        await (delete(catalogItems)
              ..where((t) => t.locationId.equals(locationId)))
            .go();
        if (rows.isNotEmpty) await batch((b) => b.insertAll(catalogItems, rows));
      });

  // ── Count sessions ─────────────────────────────────────────────────────────

  Future<List<CountSessionsData>> getAllSessions() =>
      (select(countSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> insertSession(CountSessionsCompanion row) =>
      into(countSessions).insert(row);

  Future<void> markSessionCompleted(String id) =>
      (update(countSessions)..where((t) => t.id.equals(id)))
          .write(const CountSessionsCompanion(status: Value('completed')));

  // ── Scanned items ─────────────────────────────────────────────────────────

  Future<List<ScannedItemsData>> getScannedItems(String sessionId) =>
      (select(scannedItems)..where((t) => t.sessionId.equals(sessionId))).get();

  Future<void> upsertScannedItem({
    required String sessionId,
    required String itemId,
    required String upc,
    required String name,
    required int qty,
  }) async {
    final existing = await (select(scannedItems)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.itemId.equals(itemId)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(scannedItems)
            ..where((t) => t.rowId.equals(existing.rowId)))
          .write(ScannedItemsCompanion(qty: Value(qty)));
    } else {
      await into(scannedItems).insert(ScannedItemsCompanion.insert(
        sessionId: sessionId,
        itemId: itemId,
        upc: upc,
        name: name,
        qty: qty,
      ));
    }
  }

  Future<void> removeScannedItem(String sessionId, String itemId) =>
      (delete(scannedItems)
            ..where((t) =>
                t.sessionId.equals(sessionId) & t.itemId.equals(itemId)))
          .go();

  Future<void> clearScannedItems(String sessionId) =>
      (delete(scannedItems)..where((t) => t.sessionId.equals(sessionId))).go();
}
