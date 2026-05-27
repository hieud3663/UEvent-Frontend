// File: lib/features/auth/models/auth_method.dart

/// The three authentication methods supported by the mobile app.
///
/// Google, email OTP and passkey all end with a backend-issued Keycloak token.
enum AuthMethod {
  google,
  email,
  passkey;

  /// Serialization key stored in secure storage.
  String get storageValue => name;

  /// Deserialize from the value stored in secure storage.
  static AuthMethod? fromStorageValue(String? value) {
    if (value == null) return null;
    return AuthMethod.values.where((m) => m.name == value).firstOrNull;
  }
}
