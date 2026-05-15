// File: lib/features/auth/models/auth_failure.dart

/// Sealed hierarchy of authentication failures for UI error handling.
///
/// The controller catches platform exceptions from `flutter_appauth` and
/// maps them into one of these types so the UI can show appropriate
/// snackbars / dialogs without importing platform-specific error classes.
sealed class AuthFailure implements Exception {
  const AuthFailure();

  /// A user-facing description suitable for a snackbar message.
  String get displayMessage;
}

/// The user dismissed the in-app browser before completing authentication.
class AuthFailureCancelled extends AuthFailure {
  const AuthFailureCancelled();

  @override
  String get displayMessage => 'Đăng nhập đã bị huỷ.';
}

/// A network or connectivity error prevented the auth flow from completing.
class AuthFailureNetwork extends AuthFailure {
  final String? details;
  const AuthFailureNetwork([this.details]);

  @override
  String get displayMessage => 'Lỗi kết nối. Vui lòng thử lại.';
}

/// A token refresh attempt failed definitively (e.g., refresh token revoked).
class AuthFailureRefreshFailed extends AuthFailure {
  const AuthFailureRefreshFailed();

  @override
  String get displayMessage => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
}

/// Catch-all for unexpected errors.
class AuthFailureUnknown extends AuthFailure {
  final String? message;
  const AuthFailureUnknown([this.message]);

  @override
  String get displayMessage => message ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
}
