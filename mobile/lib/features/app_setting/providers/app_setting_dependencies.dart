import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/app_setting/data/app_setting_database.dart';
import 'package:frontend/features/app_setting/data/app_setting_local_data_source.dart';
import 'package:frontend/features/app_setting/repositories/app_setting_repository.dart';
import 'package:frontend/features/app_setting/repositories/app_setting_repository_impl.dart';
import 'package:frontend/features/app_setting/services/app_version_service.dart';
import 'package:frontend/features/app_setting/services/cache_service.dart';
import 'package:frontend/features/app_setting/services/local_authentication_service.dart';
import 'package:frontend/features/app_setting/services/passkey_capability_service.dart';
import 'package:frontend/features/app_setting/services/permission_status_service.dart';

final appSettingDatabaseProvider = Provider<AppSettingDatabase>(
  (ref) => AppSettingDatabase(),
);

final appSettingLocalDataSourceProvider = Provider<AppSettingLocalDataSource>(
  (ref) => AppSettingLocalDataSource(ref.read(appSettingDatabaseProvider)),
);

final appSettingRepositoryProvider = Provider<AppSettingRepository>(
  (ref) =>
      AppSettingRepositoryImpl(ref.read(appSettingLocalDataSourceProvider)),
);

final appVersionServiceProvider = Provider<AppVersionService>(
  (ref) => const AppVersionService(),
);

final permissionStatusServiceProvider = Provider<PermissionStatusService>(
  (ref) => const PermissionStatusService(),
);

final cacheServiceProvider = Provider<CacheService>(
  (ref) => const CacheService(),
);

final localAuthenticationServiceProvider = Provider<LocalAuthenticationService>(
  (ref) => const LocalAuthenticationService(),
);

final passkeyCapabilityServiceProvider = Provider<PasskeyCapabilityService>(
  (ref) => const PasskeyCapabilityService(),
);

final passkeyCapabilityProvider = FutureProvider<bool>(
  (ref) => ref.read(passkeyCapabilityServiceProvider).isSupported(),
);

final cacheSizeProvider = FutureProvider<int>(
  (ref) => ref.read(cacheServiceProvider).estimateCacheSizeBytes(),
);
