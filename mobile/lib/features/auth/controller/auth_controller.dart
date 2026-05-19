// File: lib/features/auth/controller/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/providers/auth_providers.dart';

/// Manages the global authentication state.
///
/// State is `AsyncValue<AuthSessionModel?>`:
/// - `AsyncData(session)` → authenticated
/// - `AsyncData(null)`    → unauthenticated (or signed out)
/// - `AsyncLoading()`     → sign-in / restore in progress
/// - `AsyncError(failure)` → auth failure (shown as snackbar)
class AuthController extends AsyncNotifier<AuthSessionModel?> {
  @override
  Future<AuthSessionModel?> build() async {
    // On cold start, try to restore a session from secure storage.
    final repository = ref.read(authRepositoryProvider);
    return repository.restoreSession();
  }

  /// Initiates the PKCE sign-in flow for the given [method].
  ///
  /// Returns the session on success; throws [AuthFailure] on failure
  /// (the `AsyncError` state surfaces it to the UI).
  Future<AuthSessionModel?> signIn(
    AuthMethod method, {
    String? loginHint,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final session = await repository.signIn(method, loginHint: loginHint);
      state = AsyncData(session);
      return session;
    } on AuthFailure catch (e, st) {
      state = AsyncError(e, st);
      return null;
    } catch (e, st) {
      state = AsyncError(AuthFailureUnknown(e.toString()), st);
      return null;
    }
  }

  Future<bool> requestEmailOtp(String email) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.requestEmailOtp(email);
      state = const AsyncData(null);
      return true;
    } on AuthFailure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    } catch (e, st) {
      state = AsyncError(AuthFailureUnknown(e.toString()), st);
      return false;
    }
  }

  Future<AuthSessionModel?> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final session = await repository.verifyEmailOtp(email: email, code: code);
      state = AsyncData(session);
      return session;
    } on AuthFailure catch (e, st) {
      state = AsyncError(e, st);
      return null;
    } catch (e, st) {
      state = AsyncError(AuthFailureUnknown(e.toString()), st);
      return null;
    }
  }

  /// Explicit user-initiated sign-out.
  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = const AsyncData(null);
  }

  /// Called by the API client interceptor when a token refresh
  /// definitively fails (refresh token revoked / expired).
  ///
  /// Clears the local session and moves the state to unauthenticated.
  /// The navigation layer observes this state change and redirects to
  /// the login screen.
  Future<void> forceSignOut() async {
    final local = ref.read(authLocalDataSourceProvider);
    await local.clearSession();
    state = const AsyncData(null);
  }
}
