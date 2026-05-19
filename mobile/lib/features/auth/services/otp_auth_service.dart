import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/dtos/otp_token_dto.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';

class OtpCooldownException implements Exception {
  final int remainingSeconds;

  const OtpCooldownException(this.remainingSeconds);

  @override
  String toString() => 'Vui lòng chờ $remainingSeconds giây trước khi gửi lại.';
}

class OtpInvalidException implements Exception {
  final String message;

  const OtpInvalidException(this.message);

  @override
  String toString() => message;
}

class OtpMaxAttemptsException implements Exception {
  const OtpMaxAttemptsException();

  @override
  String toString() =>
      'Bạn đã nhập sai quá nhiều lần. Vui lòng yêu cầu mã mới.';
}

class OtpServerException implements Exception {
  final String message;

  const OtpServerException(this.message);

  @override
  String toString() => message;
}

class OtpAuthService {
  final ApiClient _apiClient;

  OtpAuthService(this._apiClient);

  Future<void> sendOtp(String email) async {
    try {
      await _apiClient.dio.post('/auth/otp/send/', data: {'email': email});
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 429) {
        final cooldown = _extractCooldown(data);
        throw OtpCooldownException(cooldown);
      }

      throw OtpServerException(
        _extractMessage(data, 'Không gửi được OTP. Vui lòng thử lại.'),
      );
    }
  }

  Future<AuthSessionModel> verifyOtp(String email, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/otp/verify/',
        data: {'email': email, 'code': code},
      );

      final dto = OtpTokenDto.fromJson(extractObjectData(response.data));
      return _dtoToSession(dto);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final message = _extractMessage(
        error.response?.data,
        'Xác thực thất bại.',
      );

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
      idToken: null,
      expiresAt: DateTime.now().add(Duration(seconds: dto.expiresIn)),
      method: AuthMethod.email,
    );
  }

  int _extractCooldown(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final value = errors['cooldown_remaining'];
        if (value is int) return value;
        if (value is num) return value.toInt();
      }
    }
    return 60;
  }

  String _extractMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return fallback;
  }
}
