// File: lib/features/auth/services/otp_auth_service.dart

import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/dtos/otp_token_dto.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';

/// Lỗi khi gửi OTP vẫn trong cooldown.
class OtpCooldownException implements Exception {
  final int remainingSeconds;
  const OtpCooldownException(this.remainingSeconds);

  @override
  String toString() =>
      'Vui lòng chờ $remainingSeconds giây trước khi gửi lại.';
}

/// OTP sai hoặc hết hạn.
class OtpInvalidException implements Exception {
  final String message;
  const OtpInvalidException(this.message);

  @override
  String toString() => message;
}

/// Nhập sai quá nhiều lần — bị khóa.
class OtpMaxAttemptsException implements Exception {
  const OtpMaxAttemptsException();

  @override
  String toString() => 'Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.';
}

/// Lỗi phía Keycloak / server không available.
class OtpServerException implements Exception {
  final String message;
  const OtpServerException(this.message);

  @override
  String toString() => message;
}

/// Service gọi 2 endpoint OTP của backend:
///   POST /auth/otp/send/
///   POST /auth/otp/verify/
///
/// Sau khi verify thành công, trả về [AuthSessionModel] đã sẵn sàng
/// để lưu vào [AuthLocalDataSource] — giống hệt session từ PKCE flow.
class OtpAuthService {
  final ApiClient _apiClient;

  OtpAuthService(this._apiClient);

  /// Gửi OTP đến [email].
  /// Throw [OtpCooldownException] nếu còn trong cooldown window.
  Future<void> sendOtp(String email) async {
    try {
      await _apiClient.dio.post(
        '/auth/otp/send/',
        data: {'email': email},
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (statusCode == 429) {
        final cooldown = data?['errors']?['cooldown_remaining'] as int? ?? 60;
        throw OtpCooldownException(cooldown);
      }
      throw OtpServerException(
        data?['message'] as String? ?? 'Không gửi được OTP. Vui lòng thử lại.',
      );
    }
  }

  /// Xác thực [code] cho [email].
  /// Thành công → trả [AuthSessionModel] chứa Keycloak tokens.
  Future<AuthSessionModel> verifyOtp(String email, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/otp/verify/',
        data: {'email': email, 'code': code},
      );

      final dto = OtpTokenDto.fromJson(extractObjectData(response.data));
      return _dtoToSession(dto);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final message = data?['message'] as String? ?? 'Xác thực thất bại.';

      if (statusCode == 429) {
        throw const OtpMaxAttemptsException();
      }
      if (statusCode == 503) {
        throw OtpServerException(message);
      }
      throw OtpInvalidException(message);
    }
  }

  AuthSessionModel _dtoToSession(OtpTokenDto dto) {
    return AuthSessionModel(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      // OTP flow không có idToken (không phải OIDC browser flow)
      idToken: null,
      expiresAt: DateTime.now().add(Duration(seconds: dto.expiresIn)),
      method: AuthMethod.email,
    );
  }
}
