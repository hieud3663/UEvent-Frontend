import 'package:flutter/material.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';

class AppVersionInfo {
  final String version;
  final String buildNumber;

  const AppVersionInfo({required this.version, required this.buildNumber});

  String get displayLabel => 'Phiên bản $version ($buildNumber)';
}

class AppSettingState {
  final Map<String, AppSetting> settings;
  final Map<AppPermissionKey, AppPermissionInfo> permissions;
  final AppVersionInfo? versionInfo;
  final Set<String> busyKeys;
  final Object? error;

  const AppSettingState({
    required this.settings,
    required this.permissions,
    this.versionInfo,
    this.busyKeys = const {},
    this.error,
  });

  bool boolValue(String key, {bool fallback = false}) {
    final value = settings[key]?.value;
    return value is bool ? value : fallback;
  }

  int intValue(String key, {int fallback = 0}) {
    final value = settings[key]?.value;
    return value is int ? value : fallback;
  }

  String stringValue(String key, {String fallback = ''}) {
    final value = settings[key]?.value;
    return value is String ? value : fallback;
  }

  ThemeMode get themeMode {
    return switch (stringValue(AppSettingKey.appearanceThemeMode)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Locale? get locale {
    return switch (stringValue(AppSettingKey.appearanceLocale)) {
      'vi' => const Locale('vi'),
      'en' => const Locale('en'),
      _ => null,
    };
  }

  bool get reduceMotionEnabled {
    return boolValue(AppSettingKey.appearanceReduceMotionEnabled);
  }

  bool get isQuietHoursActive {
    if (!boolValue(AppSettingKey.notificationQuietHoursEnabled)) {
      return false;
    }

    final start = _parseClock(
      stringValue(AppSettingKey.notificationQuietHoursStart),
    );
    final end = _parseClock(
      stringValue(AppSettingKey.notificationQuietHoursEnd),
    );
    if (start == null || end == null) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes == endMinutes) return true;
    if (startMinutes < endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }

  AppSettingState copyWith({
    Map<String, AppSetting>? settings,
    Map<AppPermissionKey, AppPermissionInfo>? permissions,
    AppVersionInfo? versionInfo,
    Set<String>? busyKeys,
    Object? error,
    bool clearError = false,
  }) {
    return AppSettingState(
      settings: settings ?? this.settings,
      permissions: permissions ?? this.permissions,
      versionInfo: versionInfo ?? this.versionInfo,
      busyKeys: busyKeys ?? this.busyKeys,
      error: clearError ? null : error ?? this.error,
    );
  }

  static TimeOfDay? _parseClock(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }
}
