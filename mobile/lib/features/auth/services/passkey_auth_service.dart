import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/passkey_credential_model.dart';
import 'package:frontend/features/auth/services/passkey_options_normalizer.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

class PasskeyAuthService {
  final ApiClient _apiClient;
  final PasskeyAuthenticator _authenticator;

  PasskeyAuthService(this._apiClient, {PasskeyAuthenticator? authenticator})
    : _authenticator = authenticator ?? PasskeyAuthenticator();

  Future<List<PasskeyCredentialModel>> listCredentials() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/auth/passkeys/',
      );
      return extractListData(
        response.data,
      ).map(PasskeyCredentialModel.fromJson).toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<PasskeyCredentialModel> register({String? deviceName}) async {
    try {
      final optionsResponse = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/passkeys/registration/options/',
      );
      final optionsPayload = extractObjectData(optionsResponse.data);
      final challengeId = _requiredString(optionsPayload, 'challenge_id');
      final request = RegisterRequestType.fromJson(
        PasskeyOptionsNormalizer.normalize(
          _requiredJsonObject(optionsPayload, 'options'),
        ),
      );

      final credential = await _authenticator.register(request);
      final verifyResponse = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/passkeys/registration/verify/',
        data: {
          'challenge_id': challengeId,
          'credential': credential.toJson(),
          'device_name': deviceName ?? _defaultDeviceName(),
        },
      );

      return PasskeyCredentialModel.fromJson(
        extractObjectData(verifyResponse.data),
      );
    } on AuthFailure {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on AuthenticatorException catch (error) {
      throw _mapPasskeyException(error);
    } catch (error) {
      throw AuthFailureUnknown(error.toString());
    }
  }

  Future<void> revoke(String credentialId) async {
    try {
      await _apiClient.dio.delete<Map<String, dynamic>>(
        '/auth/passkeys/$credentialId/',
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AuthFailure _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AuthFailureNetwork();
    }

    final message = _extractApiMessage(error.response?.data);
    if (message.isNotEmpty) return AuthFailureUnknown(message);

    return const AuthFailureUnknown(
      'Không thể cập nhật passkey. Vui lòng thử lại.',
    );
  }

  AuthFailure _mapPasskeyException(AuthenticatorException error) {
    if (error is PasskeyAuthCancelledException) {
      return const AuthFailureCancelled();
    }
    if (error is ExcludeCredentialsCanNotBeRegisteredException) {
      return const AuthFailureUnknown(
        'Thiết bị này đã có passkey cho tài khoản hiện tại.',
      );
    }
    if (error is DeviceNotSupportedException ||
        error is PasskeyUnsupportedException) {
      return const AuthFailureUnknown('Thiết bị hiện tại chưa hỗ trợ passkey.');
    }
    if (error is DomainNotAssociatedException) {
      return const AuthFailureUnknown(
        'Passkey chưa được cấu hình domain/app link đúng trên thiết bị này.',
      );
    }
    if (error is MissingGoogleSignInException ||
        error is SyncAccountNotAvailableException) {
      return const AuthFailureUnknown(
        'Vui lòng đăng nhập tài khoản Google trên thiết bị hoặc kiểm tra trình quản lý mật khẩu.',
      );
    }
    if (error is TimeoutException) {
      return const AuthFailureUnknown(
        'Phiên tạo passkey đã hết thời gian. Vui lòng thử lại.',
      );
    }
    return AuthFailureUnknown(error.toString());
  }

  String _extractApiMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return '';

    final message = data['message'] ?? data['detail'];
    final details = _flattenErrorDetails(data['errors']);
    if (details.isNotEmpty) {
      return {
        if (message is String && message.trim().isNotEmpty) message.trim(),
        ...details,
      }.join('\n');
    }
    if (message is String && message.trim().isNotEmpty) return message.trim();
    return '';
  }

  List<String> _flattenErrorDetails(Object? errors) {
    if (errors == null) return const [];
    if (errors is String) {
      final value = errors.trim();
      return value.isEmpty ? const [] : [value];
    }
    if (errors is List) {
      return errors.expand(_flattenErrorDetails).toList(growable: false);
    }
    if (errors is Map) {
      return errors.values.expand(_flattenErrorDetails).toList(growable: false);
    }
    final value = errors.toString().trim();
    return value.isEmpty ? const [] : [value];
  }

  String _requiredString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('Missing passkey field: $key');
  }

  Map<String, dynamic> _requiredJsonObject(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('Missing passkey object field: $key');
  }

  String _defaultDeviceName() {
    final platform = defaultTargetPlatform.name;
    return 'UEvent $platform';
  }
}
