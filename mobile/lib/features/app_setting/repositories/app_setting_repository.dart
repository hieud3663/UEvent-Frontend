import 'package:frontend/features/app_setting/models/app_setting.dart';

abstract class AppSettingRepository {
  Future<void> ensureDefaults();

  Future<Map<String, AppSetting>> getAll();

  Future<AppSetting?> getByKey(String key);

  Future<void> update(AppSetting setting);

  Future<Map<String, AppSetting>> resetToDefaults();
}
