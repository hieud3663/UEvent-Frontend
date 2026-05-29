// File: lib/features/auth/services/auth_service.dart

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/models/auth_failure.dart';
import 'package:frontend/features/auth/models/auth_method.dart';
import 'package:frontend/features/auth/models/auth_session_model.dart';
import 'package:frontend/features/auth/services/passkey_options_normalizer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

/// Auth gateway for mobile sign-in flows.
///
/// Google uses native Google Sign-In so users can pick an account already
/// available on the device. Email OTP and passkey use backend auth endpoints.
class AuthService {
  final FlutterAppAuth _appAuth;
  final Dio _authDio;
  final PasskeyAuthenticator _passkeyAuthenticator;
  static Future<void>? _googleInitialization;

  AuthService({
    FlutterAppAuth? appAuth,
    Dio? authDio,
    PasskeyAuthenticator? passkeyAuthenticator,
  }) : _appAuth = appAuth ?? const FlutterAppAuth(),
       _passkeyAuthenticator = passkeyAuthenticator ?? PasskeyAuthenticator(),
       _authDio =
           authDio ??
           Dio(
             BaseOptions(
               baseUrl: EnvConfig.baseUrl,
               connectTimeout: const Duration(
                 milliseconds: EnvConfig.connectTimeoutMs,
               ),
               receiveTimeout: const Duration(
                 milliseconds: EnvConfig.receiveTimeoutMs,
               ),
               headers: const {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
             ),
           );

  Future<AuthSessionModel> signIn(
    AuthMethod method, {
    String? loginHint,
  }) async {
    if (method == AuthMethod.google) {
      return _signInWithNativeGoogle();
    }
    if (method == AuthMethod.passkey) {
      return _signInWithPasskey(loginHint);
    }

    final params = switch (method) {
      AuthMethod.google => {'kc_idp_hint': 'google'},
      AuthMethod.email => {'kc_idp_hint': '', 'acr_values': 'otp'},
      AuthMethod.passkey => {'acr_values': 'passkey'},
    };

    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EnvConfig.keycloakClientId,
          EnvConfig.keycloakRedirectUri,
          issuer: EnvConfig.keycloakIssuer,
          scopes: EnvConfig.keycloakScopes,
          additionalParameters: params,
          promptValues: const ['login'],
          loginHint: loginHint,
        ),
      );

      return _mapTokenResponse(result, method);
    } on AuthFailure {
      rethrow;
    } catch (error) {
      throw _mapPlatformException(error);
    }
  }

  Future<AuthSessionModel> refreshTokens(
    String refreshToken,
    AuthMethod method,
  ) async {
    if (method == AuthMethod.email ||
        method == AuthMethod.google ||
        method == AuthMethod.passkey) {
      return _refreshBackendToken(refreshToken, method);
    }

    try {
      final result = await _appAuth.token(
        TokenRequest(
          EnvConfig.keycloakClientId,
          EnvConfig.keycloakRedirectUri,
          issuer: EnvConfig.keycloakIssuer,
          refreshToken: refreshToken,
          scopes: EnvConfig.keycloakScopes,
        ),
      );

      return _mapTokenResponse(result, method);
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailureRefreshFailed();
    }
  }

  Future<AuthSessionModel> _refreshBackendToken(
    String refreshToken,
    AuthMethod method,
  ) async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        '/auth/refresh/',
        data: {'refresh_token': refreshToken},
      );
      return _mapBackendTokenResponse(extractObjectData(response.data), method);
    } on DioException {
      throw const AuthFailureRefreshFailed();
    } catch (_) {
      throw const AuthFailureRefreshFailed();
    }
  }

  Future<AuthSessionModel> _signInWithPasskey(String? loginHint) async {
    final email = loginHint?.trim().toLowerCase() ?? '';
    final usesEmailHint = _isValidEmail(email);

    try {
      final optionsResponse = await _authDio.post<Map<String, dynamic>>(
        '/auth/passkeys/authentication/options/',
        data: usesEmailHint ? {'email': email} : <String, dynamic>{},
      );
      final optionsPayload = extractObjectData(optionsResponse.data);
      final challengeId = _requiredString(optionsPayload, 'challenge_id');
      final request = AuthenticateRequestType.fromJson(
        PasskeyOptionsNormalizer.normalize(
          _requiredJsonObject(optionsPayload, 'options'),
        ),
      );

      final credential = await _passkeyAuthenticator.authenticate(request);
      final verifyResponse = await _authDio.post<Map<String, dynamic>>(
        '/auth/passkeys/authentication/verify/',
        data: {
          if (usesEmailHint) 'email': email,
          'challenge_id': challengeId,
          'credential': credential.toJson(),
        },
      );

      return _mapBackendTokenResponse(
        extractObjectData(verifyResponse.data),
        AuthMethod.passkey,
      );
    } on AuthFailure {
      rethrow;
    } on DioException catch (error, stackTrace) {
      developer.log(
        'Backend passkey authentication failed',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapAuthDioException(error);
    } on AuthenticatorException catch (error) {
      throw _mapPasskeyException(error);
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected passkey authentication failure',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      throw AuthFailureUnknown(error.toString());
    }
  }

  Future<void> requestEmailOtp(String email) async {
    try {
      await _authDio.post<Map<String, dynamic>>(
        '/auth/otp/send/',
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (error) {
      throw _mapAuthDioException(error);
    } catch (error) {
      throw AuthFailureUnknown(error.toString());
    }
  }

  Future<AuthSessionModel> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _authDio.post<Map<String, dynamic>>(
        '/auth/otp/verify/',
        data: {'email': email.trim().toLowerCase(), 'code': code.trim()},
      );
      return _mapBackendTokenResponse(
        extractObjectData(response.data),
        AuthMethod.email,
      );
    } on DioException catch (error) {
      throw _mapAuthDioException(error);
    } catch (error) {
      throw AuthFailureUnknown(error.toString());
    }
  }

  Future<void> endSession(String idToken) async {
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: EnvConfig.keycloakPostLogoutRedirectUri,
          issuer: EnvConfig.keycloakIssuer,
        ),
      );
    } catch (_) {
      // Local logout is still valid if the remote end-session request fails.
    }
  }

  Future<void> logoutWithRefreshToken(String refreshToken) async {
    try {
      await _authDio.post<Map<String, dynamic>>(
        '/auth/logout/',
        data: {'refresh_token': refreshToken},
      );
    } catch (_) {
      // Local logout is still authoritative if remote revocation fails.
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Local logout is authoritative for the app session.
    }
  }

  Future<AuthSessionModel> _signInWithNativeGoogle() async {
    try {
      await _ensureGoogleInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AuthFailureUnknown(
          'Thiết bị hiện tại không hỗ trợ đăng nhập Google native.',
        );
      }

      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailureUnknown(
          'Không lấy được mã xác thực Google. Vui lòng thử lại.',
        );
      }

      final response = await _authDio.post<Map<String, dynamic>>(
        '/auth/google/verify/',
        data: {'id_token': idToken},
      );
      return _mapBackendTokenResponse(
        extractObjectData(response.data),
        AuthMethod.google,
      );
    } on AuthFailure {
      rethrow;
    } on GoogleSignInException catch (error, stackTrace) {
      developer.log(
        'Google Sign-In failed',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapGoogleSignInException(error);
    } on DioException catch (error, stackTrace) {
      developer.log(
        'Backend Google verification failed',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      throw _mapAuthDioException(error);
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected Google Sign-In failure',
        name: 'AuthService',
        error: error,
        stackTrace: stackTrace,
      );
      throw AuthFailureUnknown(error.toString());
    }
  }

  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: EnvConfig.googleServerClientId,
    );
  }

  AuthSessionModel _mapTokenResponse(TokenResponse result, AuthMethod method) {
    final accessToken = result.accessToken;
    final refreshToken = result.refreshToken;

    if (accessToken == null || refreshToken == null) {
      throw const AuthFailureUnknown('Keycloak không trả đủ token.');
    }

    final expiresAt =
        result.accessTokenExpirationDateTime ??
        DateTime.now().add(const Duration(minutes: 5));

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: result.idToken,
      expiresAt: expiresAt,
      method: method,
    );
  }

  AuthSessionModel _mapBackendTokenResponse(
    Map<String, dynamic> data,
    AuthMethod method,
  ) {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final expiresIn = data['expires_in'];

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthFailureUnknown('Backend không trả access token.');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthFailureUnknown('Backend không trả refresh token.');
    }

    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: data['id_token'] as String?,
      expiresAt: DateTime.now().add(
        Duration(seconds: expiresIn is int ? expiresIn : 300),
      ),
      method: method,
    );
  }

  AuthFailure _mapGoogleSignInException(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted) {
      return const AuthFailureCancelled();
    }
    if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
        error.code == GoogleSignInExceptionCode.providerConfigurationError) {
      return const AuthFailureUnknown(
        'Cấu hình Google Sign-In chưa đúng. Vui lòng kiểm tra Firebase/OAuth client.',
      );
    }
    if (error.code == GoogleSignInExceptionCode.uiUnavailable) {
      return const AuthFailureUnknown(
        'Không thể mở giao diện chọn tài khoản Google trên thiết bị này.',
      );
    }
    return AuthFailureUnknown(
      error.description ?? 'Đăng nhập Google thất bại. Vui lòng thử lại.',
    );
  }

  AuthFailure _mapPasskeyException(AuthenticatorException error) {
    if (error is PasskeyAuthCancelledException) {
      return const AuthFailureCancelled();
    }
    if (error is NoCredentialsAvailableException) {
      return const AuthFailureUnknown(
        'Không tìm thấy passkey phù hợp. Vui lòng dùng OTP hoặc tạo passkey trước.',
      );
    }
    if (error is DeviceNotSupportedException ||
        error is PasskeyUnsupportedException) {
      return const AuthFailureUnknown(
        'Thiết bị hiện tại chưa hỗ trợ passkey. Vui lòng dùng OTP.',
      );
    }
    if (error is DomainNotAssociatedException) {
      return const AuthFailureUnknown(
        'Passkey chưa được cấu hình domain/app link đúng trên thiết bị này.',
      );
    }
    if (error is MissingGoogleSignInException ||
        error is SyncAccountNotAvailableException) {
      return const AuthFailureUnknown(
        'Vui lòng đăng nhập tài khoản Google trên thiết bị hoặc dùng OTP.',
      );
    }
    if (error is TimeoutException) {
      return const AuthFailureUnknown(
        'Phiên xác thực passkey đã hết thời gian. Vui lòng thử lại.',
      );
    }
    return AuthFailureUnknown(error.toString());
  }

  AuthFailure _mapAuthDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AuthFailureNetwork();
    }

    final message = _extractApiMessage(error.response?.data);
    if (message.isNotEmpty) {
      return AuthFailureUnknown(message);
    }

    if (error.response?.statusCode == 503) {
      return const AuthFailureUnknown(
        'Máy chủ đăng nhập đang tạm thời không sẵn sàng.',
      );
    }
    return const AuthFailureUnknown('Không thể đăng nhập. Vui lòng thử lại.');
  }

  AuthFailure _mapPlatformException(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('cancel') ||
        message.contains('user_cancelled') ||
        message.contains('null')) {
      return const AuthFailureCancelled();
    }
    if (message.contains('network') || message.contains('connection')) {
      return AuthFailureNetwork(error.toString());
    }
    return AuthFailureUnknown(error.toString());
  }

  String _extractApiMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'];
      final errors = data['errors'];
      final details = _flattenErrorDetails(errors);
      if (details.isNotEmpty) {
        return {
          if (message is String && message.trim().isNotEmpty) message.trim(),
          ...details,
        }.join('\n');
      }
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
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

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
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
}
