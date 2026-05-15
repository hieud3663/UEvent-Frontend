// File: lib/features/auth/models/auth_method.dart

/// The three authentication methods supported by the Keycloak realm.
///
/// Each method maps to specific `additionalParameters` passed to
/// `flutter_appauth`'s authorization request:
/// - [google]  → `kc_idp_hint=google`
/// - [email]   → `kc_idp_hint=` (empty) + `acr_values=otp`
/// - [passkey] → `acr_values=passkey`
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
