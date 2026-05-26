import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_value_type.dart';

List<AppSetting> buildDefaultAppSettings({DateTime? updatedAt}) {
  final now = updatedAt ?? DateTime.now();

  return [
    AppSetting(
      key: AppSettingKey.notificationPushEnabled,
      valueType: AppSettingValueType.boolean,
      value: true,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationEventRemindersEnabled,
      valueType: AppSettingValueType.boolean,
      value: true,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationTicketUpdatesEnabled,
      valueType: AppSettingValueType.boolean,
      value: true,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationOrganizerUpdatesEnabled,
      valueType: AppSettingValueType.boolean,
      value: true,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationMarketingEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationQuietHoursEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationQuietHoursStart,
      valueType: AppSettingValueType.string,
      value: '22:00',
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.notificationQuietHoursEnd,
      valueType: AppSettingValueType.string,
      value: '07:00',
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.securityPreferPasskeyLogin,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.securityAppLockEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.securityBiometricUnlockEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.securityLockAfterSeconds,
      valueType: AppSettingValueType.integer,
      value: 60,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.permissionLocationFeatureEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.permissionContactsSyncEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.appearanceThemeMode,
      valueType: AppSettingValueType.string,
      value: 'system',
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.appearanceLocale,
      valueType: AppSettingValueType.string,
      value: 'system',
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.appearanceReduceMotionEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.dataAutoClearCacheEnabled,
      valueType: AppSettingValueType.boolean,
      value: false,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.dataCacheLimitMb,
      valueType: AppSettingValueType.integer,
      value: 256,
      updatedAt: now,
    ),
    AppSetting(
      key: AppSettingKey.legalPrivacyPolicyAcceptedVersion,
      valueType: AppSettingValueType.string,
      value: '',
      updatedAt: now,
    ),
  ];
}
