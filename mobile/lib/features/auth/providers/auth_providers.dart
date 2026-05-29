// File: lib/features/auth/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/controller/auth_controller.dart';
import 'package:frontend/features/auth/data_sources/local/auth_local_data_source.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/repositories/auth_repository.dart';
import 'package:frontend/features/auth/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

// ── Data Sources ──

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSourceImpl(),
);

final lastLoginEmailProvider = FutureProvider<String?>(
  (ref) => ref.read(authLocalDataSourceProvider).readLastLoginEmail(),
);

// ── Services ──

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Repository ──

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(authServiceProvider),
    ref.read(authLocalDataSourceProvider),
  ),
);

// ── Controller ──

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSessionModel?>(
      AuthController.new,
    );
