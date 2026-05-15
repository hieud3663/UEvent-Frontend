// File: lib/features/auth/models/auth_session_model.dart

import 'package:frontend/features/auth/models/auth_method.dart';

/// Represents an authenticated session with Keycloak tokens.
///
/// This model is the single source of truth for the current user's
/// authentication state and is never exposed outside the auth feature
/// as a DTO — only as this business model.
class AuthSessionModel {
  final String accessToken;
  final String refreshToken;
  final String? idToken;
  final DateTime expiresAt;
  final AuthMethod method;

  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    this.idToken,
    required this.expiresAt,
    required this.method,
  });

  /// A 30-second clock-skew margin prevents sending a token that
  /// will expire mid-flight (typical API round-trip is 1–5 s).
  static const _clockSkew = Duration(seconds: 30);

  /// Whether the access token has expired (accounting for clock skew).
  bool get isExpired => DateTime.now().isAfter(expiresAt.subtract(_clockSkew));

  /// Creates a copy with updated fields (used after token refresh).
  AuthSessionModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
    AuthMethod? method,
  }) {
    return AuthSessionModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      expiresAt: expiresAt ?? this.expiresAt,
      method: method ?? this.method,
    );
  }
}
