import 'package:app_settings/app_settings.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStatusService {
  const PermissionStatusService();

  Future<Map<AppPermissionKey, AppPermissionInfo>> getAllStatuses() async {
    final entries = await Future.wait(
      AppPermissionKey.values.map((key) async {
        return MapEntry(key, await getStatus(key));
      }),
    );
    return Map.fromEntries(entries);
  }

  Future<AppPermissionInfo> getStatus(AppPermissionKey key) async {
    try {
      final status = await _permissionFor(key).status;
      return AppPermissionInfo(key: key, status: _mapStatus(status));
    } catch (_) {
      return AppPermissionInfo(key: key, status: AppPermissionStatus.denied);
    }
  }

  Future<AppPermissionInfo> request(AppPermissionKey key) async {
    try {
      final status = await _permissionFor(key).request();
      return AppPermissionInfo(key: key, status: _mapStatus(status));
    } catch (_) {
      return AppPermissionInfo(key: key, status: AppPermissionStatus.denied);
    }
  }

  Future<void> openSystemSettings(AppPermissionKey key) async {
    try {
      await AppSettings.openAppSettings(type: _settingsTypeFor(key));
    } catch (_) {}
  }

  Permission _permissionFor(AppPermissionKey key) {
    return switch (key) {
      AppPermissionKey.notification => Permission.notification,
      AppPermissionKey.location => Permission.locationWhenInUse,
      AppPermissionKey.contacts => Permission.contacts,
      AppPermissionKey.camera => Permission.camera,
      AppPermissionKey.photos => Permission.photos,
    };
  }

  AppSettingsType _settingsTypeFor(AppPermissionKey key) {
    return switch (key) {
      AppPermissionKey.notification => AppSettingsType.notification,
      AppPermissionKey.location => AppSettingsType.location,
      AppPermissionKey.camera => AppSettingsType.camera,
      _ => AppSettingsType.settings,
    };
  }

  AppPermissionStatus _mapStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => AppPermissionStatus.granted,
      PermissionStatus.restricted => AppPermissionStatus.restricted,
      PermissionStatus.limited => AppPermissionStatus.limited,
      PermissionStatus.permanentlyDenied =>
        AppPermissionStatus.permanentlyDenied,
      PermissionStatus.provisional => AppPermissionStatus.provisional,
      PermissionStatus.denied => AppPermissionStatus.denied,
    };
  }
}
