import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:frontend/features/app_setting/models/app_setting_value_type.dart';
import 'package:frontend/features/app_setting/providers/app_setting_dependencies.dart';

class AppSettingController extends AsyncNotifier<AppSettingState> {
  bool _startupCacheMaintenanceDone = false;

  @override
  Future<AppSettingState> build() async {
    final repository = ref.read(appSettingRepositoryProvider);
    final versionService = ref.read(appVersionServiceProvider);

    await repository.ensureDefaults();
    final settings = await repository.getAll();
    await _runStartupCacheMaintenance(settings);
    final versionInfo = await versionService.getVersionInfo();

    return AppSettingState(settings: settings, versionInfo: versionInfo);
  }

  Future<void> setValue(String key, Object? value) async {
    final current = state.value;
    if (current == null) return;

    final setting = current.settings[key];
    if (setting == null) return;

    late final Object? normalizedValue;
    try {
      normalizedValue = _normalizeValue(setting.valueType, value);
    } on ArgumentError catch (error) {
      state = AsyncData(current.copyWith(error: error));
      return;
    }

    final nextSetting = setting.copyWith(
      value: normalizedValue,
      updatedAt: DateTime.now(),
    );

    state = AsyncData(current.copyWith(busyKeys: {...current.busyKeys, key}));

    try {
      await ref.read(appSettingRepositoryProvider).update(nextSetting);
      await _runSettingSideEffects(nextSetting.key, nextSetting.value);
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          settings: {...latest.settings, key: nextSetting},
          busyKeys: latest.busyKeys.difference({key}),
          clearError: true,
        ),
      );
    } catch (error) {
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(
          busyKeys: latest.busyKeys.difference({key}),
          error: error,
        ),
      );
    }
  }

  Future<void> setBool(String key, bool value) {
    return setValue(key, value);
  }

  Future<void> setString(String key, String value) {
    return setValue(key, value);
  }

  Future<void> setInt(String key, int value) {
    return setValue(key, value);
  }

  Future<void> setPreferPasskeyLogin(bool enabled) async {
    if (enabled) {
      final supported = await ref.read(passkeyCapabilityProvider.future);
      if (!supported) {
        final current = state.value;
        if (current != null) {
          state = AsyncData(
            current.copyWith(
              error: StateError('Passkey chưa khả dụng trên thiết bị này.'),
            ),
          );
        }
        return;
      }
    }

    await setBool(AppSettingKey.securityPreferPasskeyLogin, enabled);
  }

  Future<void> setBiometricUnlock(bool enabled) async {
    if (enabled) {
      final available = await canUseLocalAuthentication(biometricOnly: true);
      if (!available) {
        final current = state.value;
        if (current != null) {
          state = AsyncData(
            current.copyWith(
              error: StateError(
                'Thiết bị chưa hỗ trợ hoặc chưa thiết lập sinh trắc học.',
              ),
            ),
          );
        }
        return;
      }

      final authenticated = await _authenticateLocalUser(
        'Xác thực để bật mở khóa sinh trắc học.',
        biometricOnly: true,
      );
      if (!authenticated) return;
    }

    await setBool(AppSettingKey.securityBiometricUnlockEnabled, enabled);
  }

  Future<AppPermissionInfo?> requestPermission(AppPermissionKey key) async {
    final current = state.value;
    if (current == null) return null;

    try {
      final permission = await ref
          .read(permissionStatusServiceProvider)
          .request(key);
      state = AsyncData(current.copyWith(clearError: true));
      return permission;
    } catch (error) {
      state = AsyncData(current.copyWith(error: error));
      return null;
    }
  }

  Future<void> openSystemSettings(AppPermissionKey key) {
    return ref.read(permissionStatusServiceProvider).openSystemSettings(key);
  }

  Future<void> resetToDefaults() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await ref
          .read(appSettingRepositoryProvider)
          .resetToDefaults();
      return current.copyWith(
        settings: settings,
        busyKeys: {},
        clearError: true,
      );
    });
  }

  Future<bool> canUseLocalAuthentication({bool biometricOnly = false}) async {
    return ref
        .read(localAuthenticationServiceProvider)
        .isSupported(biometricOnly: biometricOnly);
  }

  Object? _normalizeValue(AppSettingValueType valueType, Object? value) {
    return switch (valueType) {
      AppSettingValueType.boolean when value is bool => value,
      AppSettingValueType.integer when value is int => value,
      AppSettingValueType.integer when value is num => value.round(),
      AppSettingValueType.decimal when value is num => value.toDouble(),
      AppSettingValueType.string => value?.toString() ?? '',
      AppSettingValueType.json when value is Map || value is List => value,
      _ => throw ArgumentError.value(
        value,
        'value',
        'Giá trị không khớp kiểu ${valueType.wireName}',
      ),
    };
  }

  Future<bool> _authenticateLocalUser(
    String reason, {
    bool biometricOnly = false,
  }) async {
    return ref
        .read(localAuthenticationServiceProvider)
        .authenticate(reason, biometricOnly: biometricOnly);
  }

  Future<void> _runStartupCacheMaintenance(
    Map<String, AppSetting> settings,
  ) async {
    if (_startupCacheMaintenanceDone) return;
    _startupCacheMaintenanceDone = true;

    try {
      final cacheService = ref.read(cacheServiceProvider);
      if (settings[AppSettingKey.dataAutoClearCacheEnabled]?.value == true) {
        await cacheService.clearTemporaryCache();
        return;
      }

      final limitMb = settings[AppSettingKey.dataCacheLimitMb]?.value;
      if (limitMb is int && limitMb > 0) {
        await cacheService.trimTemporaryCacheToLimit(limitMb * 1024 * 1024);
      }
    } catch (_) {
      // Không làm hỏng quá trình tải app nếu tác vụ cache nền thất bại.
    }
  }

  Future<void> _runSettingSideEffects(String key, Object? value) async {
    if (key != AppSettingKey.dataCacheLimitMb || value is! int || value <= 0) {
      return;
    }

    try {
      await ref
          .read(cacheServiceProvider)
          .trimTemporaryCacheToLimit(value * 1024 * 1024);
    } catch (_) {
      // Giữ setting đã lưu; lỗi dọn cache sẽ được xử lý ở lần kiểm tra sau.
    }
  }
}
