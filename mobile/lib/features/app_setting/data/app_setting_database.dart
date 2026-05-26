import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppSettingDatabase {
  static const int schemaVersion = 2;

  final String databaseName;
  Database? _database;

  AppSettingDatabase({this.databaseName = 'uevent_app.db'});

  Future<Database> get database async {
    final current = _database;
    if (current != null) return current;

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(databasePath, databaseName),
      version: schemaVersion,
      onCreate: (db, version) => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) => _createSchema(db),
      onOpen: _writeMeta,
    );

    _database = database;
    return database;
  }

  Future<void> close() async {
    final current = _database;
    if (current == null) return;

    await current.close();
    _database = null;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  value_type TEXT NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS app_setting_meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)
''');
  }

  Future<void> _writeMeta(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final batch = db.batch();

    batch.insert('app_setting_meta', {
      'key': 'schema_version',
      'value': schemaVersion.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    batch.insert('app_setting_meta', {
      'key': 'updated_at',
      'value': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await batch.commit(noResult: true);
  }
}
