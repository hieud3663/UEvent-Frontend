// File: lib/features/auth/repositories/auth_repository_impl.dart

import 'package:frontend/features/auth/data_sources/local/auth_local_data_source.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/repositories/auth_repository.dart';
import 'package:frontend/features/auth/services/auth_service.dart';

/// Production implementation that composes [AuthService] (remote IO via
/// `flutter_appauth`) and [AuthLocalDataSource] (secure token storage).
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._service, this._local);

  @override
  Future<AuthSessionModel> signIn(
    AuthMethod method, {
    String? loginHint,
  }) async {
    final session = await _service.signIn(method, loginHint: loginHint);
    await _local.writeSession(session);
    return session;
  }

  @override
  Future<void> requestEmailOtp(String email) {
    return _service.requestEmailOtp(email);
  }

  @override
  Future<AuthSessionModel> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final session = await _service.verifyEmailOtp(email: email, code: code);
    await _local.writeSession(session);
    return session;
  }

  @override
  Future<void> refreshTokens() async {
    final current = await _local.readSession();
    if (current == null) {
      throw StateError('Cannot refresh tokens: no session found.');
    }

    final refreshed = await _service.refreshTokens(
      current.refreshToken,
      current.method,
    );
    await _local.writeSession(refreshed);
  }

  @override
  Future<void> signOut() async {
    final current = await _local.readSession();

    // Clear local storage first — even if end-session fails,
    // the user should still be logged out of the app.
    await _local.clearSession();

    if (current != null) {
      await _service.logoutWithRefreshToken(current.refreshToken);
    }

    if (current?.idToken != null) {
      await _service.endSession(current!.idToken!);
    }
    if (current?.method == AuthMethod.google) {
      await _service.signOutGoogle();
    }
  }

  @override
  Future<AuthSessionModel?> restoreSession() async {
    return _local.readSession();
  }
}
