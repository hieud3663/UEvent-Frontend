import 'package:frontend/features/app_setting/data/app_setting_defaults.dart';
import 'package:frontend/features/app_setting/data/app_setting_local_data_source.dart';
import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:frontend/features/app_setting/repositories/app_setting_repository.dart';

class AppSettingRepositoryImpl implements AppSettingRepository {
  final AppSettingLocalDataSource _localDataSource;

  const AppSettingRepositoryImpl(this._localDataSource);

  @override
  Future<void> ensureDefaults() {
    return _localDataSource.insertMissingDefaults(buildDefaultAppSettings());
  }

  @override
  Future<Map<String, AppSetting>> getAll() async {
    final settings = await _localDataSource.getAll();
    return {for (final setting in settings) setting.key: setting};
  }

  @override
  Future<AppSetting?> getByKey(String key) {
    return _localDataSource.getByKey(key);
  }

  @override
  Future<void> update(AppSetting setting) {
    return _localDataSource.upsert(setting);
  }

  @override
  Future<Map<String, AppSetting>> resetToDefaults() async {
    final defaults = buildDefaultAppSettings();
    await _localDataSource.replaceAll(defaults);
    return {for (final setting in defaults) setting.key: setting};
  }
}
