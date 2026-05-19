sealed class AuthFailure implements Exception {
  const AuthFailure();

  String get displayMessage;
}

class AuthFailureCancelled extends AuthFailure {
  const AuthFailureCancelled();

  @override
  String get displayMessage => 'Đăng nhập đã bị hủy.';
}

class AuthFailureNetwork extends AuthFailure {
  final String? details;

  const AuthFailureNetwork([this.details]);

  @override
  String get displayMessage => 'Lỗi kết nối. Vui lòng thử lại.';
}

class AuthFailureRefreshFailed extends AuthFailure {
  const AuthFailureRefreshFailed();

  @override
  String get displayMessage =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
}

class AuthFailureUnknown extends AuthFailure {
  final String? message;

  const AuthFailureUnknown([this.message]);

  @override
  String get displayMessage => message ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
}
