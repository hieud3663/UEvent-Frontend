// File: lib/features/auth/repositories/auth_repository.dart

import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';

/// Abstract interface for authentication operations.
///
/// The controller depends on this interface — never on the implementation.
/// This allows swapping between real and mock implementations via the
/// service locator / provider layer.
abstract interface class AuthRepository {
  /// Launches the PKCE flow for the given [method] and persists the session.
  Future<AuthSessionModel> signIn(AuthMethod method, {String? loginHint});

  /// Silently refreshes the access token using the stored refresh token.
  /// Throws [AuthFailureRefreshFailed] if the refresh token is invalid.
  Future<void> refreshTokens();

  /// Signs out: hits Keycloak's end-session endpoint, then clears local storage.
  Future<void> signOut();

  /// Attempts to restore a session from secure storage.
  /// Returns `null` if no valid session exists (no tokens or expired refresh).
  Future<AuthSessionModel?> restoreSession();
}
