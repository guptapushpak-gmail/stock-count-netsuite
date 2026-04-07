import 'dart:io';

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
  BoolColumn get isLotItem => boolean().withDefault(const Constant(false))();
  BoolColumn get isSerialItem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id, locationId};
}

@DataClassName('DbSession')
class CountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get locationId => text()();
  TextColumn get locationName => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get memo => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbScannedItem')
class ScannedItems extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get itemId => text()();
  TextColumn get upc => text()();
  TextColumn get name => text()();
  IntColumn get qty => integer()();
  BoolColumn get isLotItem => boolean().withDefault(const Constant(false))();
  BoolColumn get isSerialItem => boolean().withDefault(const Constant(false))();
  TextColumn get lotSerialData => text().nullable()();
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
            'ALTER TABLE catalog_items ADD COLUMN is_lot_item INTEGER NOT NULL DEFAULT 0');
        await customStatement(
            'ALTER TABLE catalog_items ADD COLUMN is_serial_item INTEGER NOT NULL DEFAULT 0');
        await customStatement(
            'ALTER TABLE scanned_items ADD COLUMN is_lot_item INTEGER NOT NULL DEFAULT 0');
        await customStatement(
            'ALTER TABLE scanned_items ADD COLUMN is_serial_item INTEGER NOT NULL DEFAULT 0');
        await customStatement(
            'ALTER TABLE scanned_items ADD COLUMN lot_serial_data TEXT');
      }
      if (from < 3) {
        await customStatement(
            "ALTER TABLE count_sessions ADD COLUMN memo TEXT NOT NULL DEFAULT ''");
      }
    },
  );

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

  Future<List<Location>> getAllLocations() =>
      (select(locations)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<void> replaceLocations(List<LocationsCompanion> rows) =>
      transaction(() async {
        await delete(locations).go();
        if (rows.isNotEmpty) await batch((b) => b.insertAll(locations, rows));
      });

  // ── Adjustment accounts ────────────────────────────────────────────────────

  Future<List<AdjustmentAccount>> getAllAccounts() =>
      select(adjustmentAccounts).get();

  Future<void> replaceAccounts(List<AdjustmentAccountsCompanion> rows) =>
      transaction(() async {
        await delete(adjustmentAccounts).go();
        if (rows.isNotEmpty) await batch((b) => b.insertAll(adjustmentAccounts, rows));
      });

  // ── Catalog items ─────────────────────────────────────────────────────────

  Future<List<CatalogItem>> getItemsForLocation(String locationId) =>
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

  Future<List<DbSession>> getAllSessions() =>
      (select(countSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> insertSession(CountSessionsCompanion row) =>
      into(countSessions).insert(row);

  Future<void> markSessionCompleted(String id) =>
      (update(countSessions)..where((t) => t.id.equals(id)))
          .write(const CountSessionsCompanion(status: Value('completed')));

  // ── Scanned items ─────────────────────────────────────────────────────────

  /// Returns {sessionId: (skuCount, totalQty)} for all sessions.
  Future<Map<String, ({int skuCount, int totalQty})>> getAllSessionCounts() async {
    final rows = await customSelect(
      'SELECT session_id, COUNT(*) AS sku_count, SUM(qty) AS total_qty '
      'FROM scanned_items GROUP BY session_id',
    ).get();
    return {
      for (final r in rows)
        r.read<String>('session_id'): (
          skuCount: r.read<int>('sku_count'),
          totalQty: r.read<int>('total_qty'),
        )
    };
  }

  Future<List<DbScannedItem>> getScannedItems(String sessionId) =>
      (select(scannedItems)..where((t) => t.sessionId.equals(sessionId))).get();

  Future<void> upsertScannedItem({
    required String sessionId,
    required String itemId,
    required String upc,
    required String name,
    required int qty,
    bool isLotItem = false,
    bool isSerialItem = false,
    String? lotSerialData,
  }) async {
    final existing = await (select(scannedItems)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.itemId.equals(itemId)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(scannedItems)
            ..where((t) => t.rowId.equals(existing.rowId)))
          .write(ScannedItemsCompanion(
            qty: Value(qty),
            lotSerialData: Value(lotSerialData),
          ));
    } else {
      await into(scannedItems).insert(ScannedItemsCompanion.insert(
        sessionId: sessionId,
        itemId: itemId,
        upc: upc,
        name: name,
        qty: qty,
        isLotItem: Value(isLotItem),
        isSerialItem: Value(isSerialItem),
        lotSerialData: Value(lotSerialData),
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

  Future<void> deleteSession(String sessionId) => transaction(() async {
        await (delete(scannedItems)..where((t) => t.sessionId.equals(sessionId))).go();
        await (delete(countSessions)..where((t) => t.id.equals(sessionId))).go();
      });
}
