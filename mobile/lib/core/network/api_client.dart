// File: lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/features/auth/data_sources/local/auth_local_data_source.dart';

/// Central HTTP client with automatic token injection and single-flight
/// 401 refresh.
///
/// Dependencies are injected at construction time via lazy lambdas to
/// avoid circular provider resolution:
/// - [authLocal]: reads the current access token.
/// - [refreshFn]: calls `AuthRepository.refreshTokens()`.
/// - [onForceSignOut]: moves `AuthController` to unauthenticated state.
///
/// The refresh path itself (`flutter_appauth.token()`) never goes through
/// this client, so no circular dependency exists.
class ApiClient {
  late final Dio dio;

  final AuthLocalDataSource _authLocal;
  final Future<void> Function() _refreshFn;
  final Future<void> Function() _onForceSignOut;

  /// Single-flight lock for 401 refresh — `null` when idle.
  /// `??=` is atomic in Dart's single-isolate model, so even if
  /// multiple parallel 401 handlers hit this line in the same microtask
  /// boundary, only one `_doRefresh()` runs; the others await the same
  /// future.
  Future<bool>? _refreshFlight;

  ApiClient({
    required AuthLocalDataSource authLocal,
    required Future<void> Function() refreshFn,
    required Future<void> Function() onForceSignOut,
  })  : _authLocal = authLocal,
        _refreshFn = refreshFn,
        _onForceSignOut = onForceSignOut {
    dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: EnvConfig.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: EnvConfig.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _injectToken,
        onError: _handleAuthError,
      ),
    );
  }

  // ── Token Injection ──

  Future<void> _injectToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth endpoints — they carry credentials in the body, not Bearer.
    if (options.path.contains('/protocol/openid-connect/')) {
      return handler.next(options);
    }

    final session = await _authLocal.readSession();
    if (session != null && !session.isExpired) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    // Expired or missing: let request go without a token.
    // If the server returns 401, the error handler will refresh-and-retry.
    return handler.next(options);
  }

  // ── 401 Refresh + Retry ──

  Future<void> _handleAuthError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;

    // Only intercept 401 Unauthorized.
    if (error.response?.statusCode != 401) return handler.next(error);

    // Never retry more than once to prevent infinite loops.
    if (request.extra['retried'] == true) return handler.next(error);

    // Don't try to refresh if the 401 came from the token endpoint itself
    // (the refresh token was rejected).
    if (request.path.contains('/protocol/openid-connect/')) {
      return handler.next(error);
    }

    final refreshSucceeded = await _refreshSingleFlight();

    if (!refreshSucceeded) {
      // Refresh definitively failed → force sign-out and propagate.
      await _onForceSignOut();
      return handler.next(error);
    }

    // Replay the original request with the new token.
    final session = await _authLocal.readSession();
    request.extra['retried'] = true;
    request.headers['Authorization'] = 'Bearer ${session!.accessToken}';

    try {
      final response = await dio.fetch(request);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Ensures exactly one refresh call runs at a time.
  Future<bool> _refreshSingleFlight() {
    return _refreshFlight ??=
        _doRefresh().whenComplete(() => _refreshFlight = null);
  }

  Future<bool> _doRefresh() async {
    try {
      await _refreshFn();
      return true;
    } catch (_) {
      return false;
    }
  }
}
