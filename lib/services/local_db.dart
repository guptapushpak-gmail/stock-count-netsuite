import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'stock_count.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE count_sessions(
            id TEXT PRIMARY KEY,
            locationId TEXT,
            status TEXT,
            createdAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE scanned_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId TEXT,
            sku TEXT,
            name TEXT,
            qty INTEGER,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }
}
