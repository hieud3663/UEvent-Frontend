import 'package:frontend/features/app_setting/data/app_setting_database.dart';
import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:sqflite/sqflite.dart';

class AppSettingLocalDataSource {
  final AppSettingDatabase _database;

  const AppSettingLocalDataSource(this._database);

  Future<List<AppSetting>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('app_settings', orderBy: 'key ASC');
    return rows.map(AppSetting.fromRow).toList(growable: false);
  }

  Future<AppSetting?> getByKey(String key) async {
    final db = await _database.database;
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppSetting.fromRow(rows.first);
  }

  Future<void> upsert(AppSetting setting) async {
    final db = await _database.database;
    await db.insert(
      'app_settings',
      setting.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMissingDefaults(List<AppSetting> defaults) async {
    final db = await _database.database;
    final batch = db.batch();

    for (final setting in defaults) {
      batch.insert(
        'app_settings',
        setting.toRow(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> replaceAll(List<AppSetting> settings) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('app_settings');
      final batch = txn.batch();
      for (final setting in settings) {
        batch.insert('app_settings', setting.toRow());
      }
      await batch.commit(noResult: true);
    });
  }
}
