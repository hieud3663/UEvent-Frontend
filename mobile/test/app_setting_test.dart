import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/localization/app_localizations.dart';
import 'package:frontend/features/app_setting/data/app_setting_defaults.dart';
import 'package:frontend/features/app_setting/data/app_setting_database.dart';
import 'package:frontend/features/app_setting/data/app_setting_local_data_source.dart';
import 'package:frontend/features/app_setting/models/app_permission.dart';
import 'package:frontend/features/app_setting/models/app_setting.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:frontend/features/app_setting/models/app_setting_value_type.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/app_setting/repositories/app_setting_repository.dart';
import 'package:frontend/features/app_setting/repositories/app_setting_repository_impl.dart';
import 'package:frontend/features/app_setting/services/app_version_service.dart';
import 'package:frontend/features/app_setting/services/cache_service.dart';
import 'package:frontend/features/app_setting/services/local_authentication_service.dart';
import 'package:frontend/features/app_setting/services/passkey_capability_service.dart';
import 'package:frontend/features/app_setting/services/permission_status_service.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/notifications/models/notification_category.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('app_setting defaults', () {
    test('seed đầy đủ các key cốt lõi cho mobile', () {
      final settings = {
        for (final setting in buildDefaultAppSettings()) setting.key: setting,
      };

      expect(settings[AppSettingKey.notificationPushEnabled]?.value, isTrue);
      expect(
        settings[AppSettingKey.securityPreferPasskeyLogin]?.value,
        isFalse,
      );
      expect(settings[AppSettingKey.appearanceThemeMode]?.value, 'system');
      expect(settings[AppSettingKey.dataCacheLimitMb]?.value, 256);
      expect(
        settings.containsKey(AppSettingKey.legalPrivacyPolicyAcceptedVersion),
        isTrue,
      );
    });
  });

  group('AppSettingValueType', () {
    test('mã hóa và giải mã bool/int/string/json ổn định', () {
      expect(AppSettingValueType.boolean.decode('true'), isTrue);
      expect(AppSettingValueType.boolean.encode(false), 'false');

      expect(AppSettingValueType.integer.decode('42'), 42);
      expect(AppSettingValueType.integer.encode(9), '9');

      expect(AppSettingValueType.string.decode('vi'), 'vi');
      expect(AppSettingValueType.string.encode('system'), 'system');

      final rawJson = AppSettingValueType.json.encode({'quiet_hours': true});
      expect(AppSettingValueType.json.decode(rawJson), {'quiet_hours': true});
    });

    test('JSON hỏng không làm crash app_setting', () {
      expect(AppSettingValueType.json.decode('{bad json'), isA<Map>());
    });
  });

  group('AppSettingState', () {
    test('map theme và locale có fallback an toàn', () {
      final defaults = {
        for (final setting in buildDefaultAppSettings()) setting.key: setting,
      };
      final state = AppSettingState(
        settings: {
          ...defaults,
          AppSettingKey.appearanceThemeMode:
              defaults[AppSettingKey.appearanceThemeMode]!.copyWith(
                value: 'khong-hop-le',
              ),
          AppSettingKey.appearanceLocale:
              defaults[AppSettingKey.appearanceLocale]!.copyWith(value: 'vi'),
        },
        permissions: const {},
      );

      expect(state.themeMode, ThemeMode.system);
      expect(state.locale, const Locale('vi'));
    });

    test('quiet hours không active khi dữ liệu giờ bị lỗi', () {
      final defaults = {
        for (final setting in buildDefaultAppSettings()) setting.key: setting,
      };
      final state = AppSettingState(
        settings: {
          ...defaults,
          AppSettingKey.notificationQuietHoursEnabled:
              defaults[AppSettingKey.notificationQuietHoursEnabled]!.copyWith(
                value: true,
              ),
          AppSettingKey.notificationQuietHoursStart:
              defaults[AppSettingKey.notificationQuietHoursStart]!.copyWith(
                value: 'sai',
              ),
        },
        permissions: const {},
      );

      expect(state.isQuietHoursActive, isFalse);
    });
  });

  group('AppSettingRepositoryImpl SQLite', () {
    late AppSettingDatabase settingDatabase;
    late AppSettingRepositoryImpl repository;

    setUp(() {
      settingDatabase = AppSettingDatabase(
        databaseName:
            'uevent_app_setting_test_${DateTime.now().microsecondsSinceEpoch}.db',
      );
      repository = AppSettingRepositoryImpl(
        AppSettingLocalDataSource(settingDatabase),
      );
    });

    tearDown(() async {
      final databasePath = await getDatabasesPath();
      final fullPath = p.join(databasePath, settingDatabase.databaseName);
      await settingDatabase.close();
      await databaseFactory.deleteDatabase(fullPath);
    });

    test('mở database sẽ ghi metadata schema', () async {
      final db = await settingDatabase.database;
      final rows = await db.query('app_setting_meta');
      final meta = {for (final row in rows) row['key']: row['value']};

      expect(
        meta['schema_version'],
        AppSettingDatabase.schemaVersion.toString(),
      );
      expect(meta['updated_at'], isA<String>());
    });

    test('seed, cập nhật và reset default trên SQLite local', () async {
      await repository.ensureDefaults();

      final seeded = await repository.getAll();
      expect(seeded[AppSettingKey.notificationPushEnabled]?.value, isTrue);

      final pushSetting = seeded[AppSettingKey.notificationPushEnabled]!;
      await repository.update(pushSetting.copyWith(value: false));

      final updated = await repository.getAll();
      expect(updated[AppSettingKey.notificationPushEnabled]?.value, isFalse);

      final reset = await repository.resetToDefaults();
      expect(reset[AppSettingKey.notificationPushEnabled]?.value, isTrue);
    });

    test('đọc được setting JSON hỏng trong SQLite', () async {
      final db = await settingDatabase.database;
      await db.insert('app_settings', {
        'key': 'test.json_corrupted',
        'value': '{bad json',
        'value_type': AppSettingValueType.json.wireName,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final setting = await repository.getByKey('test.json_corrupted');

      expect(setting?.value, isA<Map>());
    });
  });

  group('AppSettingController', () {
    test('không ghi setting sai kiểu xuống repository', () async {
      final repository = _FakeAppSettingRepository();
      final container = ProviderContainer(
        overrides: [
          appSettingRepositoryProvider.overrideWithValue(repository),
          permissionStatusServiceProvider.overrideWithValue(
            const _FakePermissionStatusService(),
          ),
          appVersionServiceProvider.overrideWithValue(
            const _FakeAppVersionService(),
          ),
          localAuthenticationServiceProvider.overrideWithValue(
            const _FakeLocalAuthenticationService(supported: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appSettingControllerProvider.future);
      await container
          .read(appSettingControllerProvider.notifier)
          .setValue(AppSettingKey.notificationPushEnabled, 'sai kiểu');

      final state = container.read(appSettingControllerProvider).value!;
      expect(repository.updatedSettings, isEmpty);
      expect(state.error, isA<ArgumentError>());
      expect(state.boolValue(AppSettingKey.notificationPushEnabled), isTrue);
    });

    test('normalize số trước khi ghi setting integer', () async {
      final repository = _FakeAppSettingRepository();
      final container = ProviderContainer(
        overrides: [
          appSettingRepositoryProvider.overrideWithValue(repository),
          permissionStatusServiceProvider.overrideWithValue(
            const _FakePermissionStatusService(),
          ),
          appVersionServiceProvider.overrideWithValue(
            const _FakeAppVersionService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appSettingControllerProvider.future);
      await container
          .read(appSettingControllerProvider.notifier)
          .setValue(AppSettingKey.dataCacheLimitMb, 512.4);

      expect(repository.updatedSettings.single.value, 512);
      final state = container.read(appSettingControllerProvider).value!;
      expect(state.intValue(AppSettingKey.dataCacheLimitMb), 512);
    });

    test('không bật sinh trắc học khi thiết bị không hỗ trợ', () async {
      final repository = _FakeAppSettingRepository();
      final container = ProviderContainer(
        overrides: [
          appSettingRepositoryProvider.overrideWithValue(repository),
          permissionStatusServiceProvider.overrideWithValue(
            const _FakePermissionStatusService(),
          ),
          appVersionServiceProvider.overrideWithValue(
            const _FakeAppVersionService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appSettingControllerProvider.future);
      await container
          .read(appSettingControllerProvider.notifier)
          .setBiometricUnlock(true);

      final state = container.read(appSettingControllerProvider).value!;
      expect(repository.updatedSettings, isEmpty);
      expect(
        state.boolValue(AppSettingKey.securityBiometricUnlockEnabled),
        isFalse,
      );
      expect(state.error, isA<StateError>());
    });

    test('không bật ưu tiên passkey khi thiết bị không hỗ trợ', () async {
      final repository = _FakeAppSettingRepository();
      final container = ProviderContainer(
        overrides: [
          appSettingRepositoryProvider.overrideWithValue(repository),
          permissionStatusServiceProvider.overrideWithValue(
            const _FakePermissionStatusService(),
          ),
          appVersionServiceProvider.overrideWithValue(
            const _FakeAppVersionService(),
          ),
          passkeyCapabilityServiceProvider.overrideWithValue(
            const PasskeyCapabilityService(
              platformOverride: TargetPlatform.linux,
              webOverride: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appSettingControllerProvider.future);
      await container
          .read(appSettingControllerProvider.notifier)
          .setPreferPasskeyLogin(true);

      final state = container.read(appSettingControllerProvider).value!;
      expect(repository.updatedSettings, isEmpty);
      expect(
        state.boolValue(AppSettingKey.securityPreferPasskeyLogin),
        isFalse,
      );
      expect(state.error, isA<StateError>());
    });
  });

  group('PasskeyCapabilityService', () {
    test('chỉ bật mặc định cho web hoặc Android/iOS', () async {
      expect(
        await const PasskeyCapabilityService(
          platformOverride: TargetPlatform.android,
          webOverride: false,
        ).isSupported(),
        isTrue,
      );
      expect(
        await const PasskeyCapabilityService(
          platformOverride: TargetPlatform.windows,
          webOverride: false,
        ).isSupported(),
        isFalse,
      );
      expect(
        await const PasskeyCapabilityService(
          platformOverride: TargetPlatform.linux,
          webOverride: true,
        ).isSupported(),
        isTrue,
      );
    });
  });

  group('AppLocalizations', () {
    test('trả text theo locale được chọn', () {
      expect(
        const AppLocalizations(Locale('vi')).passkeyLogin,
        'Đăng nhập bằng Passkey',
      );
      expect(
        const AppLocalizations(Locale('en')).passkeyLogin,
        'Sign in with Passkey',
      );
    });

    testWidgets(
      'LoginView dùng locale tiếng Anh và ẩn passkey khi unsupported',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            supportedLocales: [Locale('vi'), Locale('en')],
            localizationsDelegates: [AppLocalizations.delegate],
            home: LoginView(preferPasskey: true, passkeyAvailable: false),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sign in to continue'), findsOneWidget);
        expect(
          find.text('Passkey is not available on this device.'),
          findsOneWidget,
        );
        expect(find.text('Sign in with Passkey'), findsNothing);
      },
    );
  });

  group('CacheService', () {
    late Directory tempDir;
    late CacheService cacheService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('uevent_cache_test_');
      cacheService = CacheService(
        temporaryDirectoryProvider: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('trimTemporaryCacheToLimit xóa file cũ trước', () async {
      final oldFile = File(p.join(tempDir.path, 'old.tmp'));
      final newFile = File(p.join(tempDir.path, 'new.tmp'));
      await oldFile.writeAsBytes(List<int>.filled(10, 1));
      await newFile.writeAsBytes(List<int>.filled(10, 1));
      await oldFile.setLastModified(DateTime(2024));
      await newFile.setLastModified(DateTime(2025));

      final result = await cacheService.trimTemporaryCacheToLimit(12);

      expect(result.deletedEntries, 1);
      expect(await oldFile.exists(), isFalse);
      expect(await newFile.exists(), isTrue);
      expect(
        await cacheService.estimateCacheSizeBytes(),
        lessThanOrEqualTo(12),
      );
    });

    test('clearTemporaryCache trả về số liệu dọn dẹp', () async {
      final file = File(p.join(tempDir.path, 'cache.tmp'));
      await file.writeAsBytes(List<int>.filled(8, 1));

      final result = await cacheService.clearTemporaryCache();

      expect(result.bytesBefore, 8);
      expect(result.bytesAfter, 0);
      expect(result.freedBytes, 8);
    });
  });

  group('NotificationCategory', () {
    test('phân loại payload notification ổn định', () {
      expect(
        NotificationCategory.fromPayload({'type': 'ticket_update'}),
        NotificationCategory.ticket,
      );
      expect(
        NotificationCategory.fromPayload({'notification_type': 'organizer'}),
        NotificationCategory.organizer,
      );
      expect(
        NotificationCategory.fromPayload({'category': 'promotion'}),
        NotificationCategory.marketing,
      );
      expect(
        NotificationCategory.fromPayload({'type': 'event_reminder'}),
        NotificationCategory.event,
      );
      expect(
        NotificationCategory.fromPayload({'type': 'system'}),
        NotificationCategory.unknown,
      );
    });
  });
}

class _FakeAppSettingRepository implements AppSettingRepository {
  final List<AppSetting> updatedSettings = [];
  Map<String, AppSetting> _settings = {};

  @override
  Future<void> ensureDefaults() async {
    _settings = {
      for (final setting in buildDefaultAppSettings()) setting.key: setting,
    };
  }

  @override
  Future<Map<String, AppSetting>> getAll() async {
    return Map<String, AppSetting>.from(_settings);
  }

  @override
  Future<AppSetting?> getByKey(String key) async {
    return _settings[key];
  }

  @override
  Future<void> update(AppSetting setting) async {
    updatedSettings.add(setting);
    _settings = {..._settings, setting.key: setting};
  }

  @override
  Future<Map<String, AppSetting>> resetToDefaults() async {
    await ensureDefaults();
    return getAll();
  }
}

class _FakePermissionStatusService extends PermissionStatusService {
  const _FakePermissionStatusService();

  @override
  Future<Map<AppPermissionKey, AppPermissionInfo>> getAllStatuses() async {
    return {
      for (final key in AppPermissionKey.values)
        key: AppPermissionInfo(key: key, status: AppPermissionStatus.denied),
    };
  }
}

class _FakeAppVersionService extends AppVersionService {
  const _FakeAppVersionService();

  @override
  Future<AppVersionInfo> getVersionInfo() async {
    return const AppVersionInfo(version: '1.0.0', buildNumber: '1');
  }
}

class _FakeLocalAuthenticationService extends LocalAuthenticationService {
  final bool supported;

  const _FakeLocalAuthenticationService({required this.supported});

  @override
  Future<bool> isSupported({bool biometricOnly = false}) async {
    return supported;
  }

  @override
  Future<bool> authenticate(String reason, {bool biometricOnly = false}) async {
    return false;
  }
}
