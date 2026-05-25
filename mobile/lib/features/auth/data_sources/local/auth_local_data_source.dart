// File: lib/features/auth/data_sources/local/auth_local_data_source.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';

// ── Storage keys ──
const _kAccessToken = 'auth_access_token';
const _kRefreshToken = 'auth_refresh_token';
const _kIdToken = 'auth_id_token';
const _kExpiresAt = 'auth_expires_at'; // epoch milliseconds
const _kMethod = 'auth_method';

// ── Platform-specific options ──
// first_unlock (NOT whenUnlocked): tokens readable while screen is locked,
// so a foreground 401-refresh during a notification-tap flow still works.
const _iosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock,
);

// EncryptedSharedPreferences requires minSdk 23 (enforced in build.gradle.kts).
const _androidOptions = AndroidOptions(encryptedSharedPreferences: true);

/// Abstract interface for auth session persistence.
///
/// The repository depends on this interface — never on the concrete
/// implementation — so it can be swapped in tests.
abstract interface class AuthLocalDataSource {
  /// Returns the persisted session, or `null` if nothing is stored.
  Future<AuthSessionModel?> readSession();

  /// Overwrites all stored fields atomically.
  Future<void> writeSession(AuthSessionModel session);

  /// Deletes all auth-related keys (sign-out / force-sign-out).
  Future<void> clearSession();
}

/// Concrete implementation backed by [FlutterSecureStorage].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: _iosOptions,
            aOptions: _androidOptions,
          );

  @override
  Future<AuthSessionModel?> readSession() async {
    final accessToken = await _storage.read(key: _kAccessToken);
    final refreshToken = await _storage.read(key: _kRefreshToken);

    // Both tokens are mandatory for a valid session.
    if (accessToken == null || refreshToken == null) return null;

    final idToken = await _storage.read(key: _kIdToken);
    final expiresAtMs = await _storage.read(key: _kExpiresAt);
    final methodRaw = await _storage.read(key: _kMethod);

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: expiresAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(expiresAtMs))
          : DateTime.now(), // treat missing expiry as already expired
      method: AuthMethod.fromStorageValue(methodRaw) ?? AuthMethod.email,
    );
  }

  @override
  Future<void> writeSession(AuthSessionModel session) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: session.accessToken),
      _storage.write(key: _kRefreshToken, value: session.refreshToken),
      if (session.idToken != null)
        _storage.write(key: _kIdToken, value: session.idToken),
      _storage.write(
        key: _kExpiresAt,
        value: session.expiresAt.millisecondsSinceEpoch.toString(),
      ),
      _storage.write(key: _kMethod, value: session.method.storageValue),
    ]);
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kIdToken),
      _storage.delete(key: _kExpiresAt),
      _storage.delete(key: _kMethod),
    ]);
  }
}
