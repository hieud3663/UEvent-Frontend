import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
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
        onRequest: (options, handler) {
          // TODO: Fetch access token from secure storage and inject it here
          // final token = await _secureStorage.read(key: 'accessToken');
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer \$token';
          // }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // TODO: Handle 401 Unauthorized for token refresh
          // if (e.response?.statusCode == 401) {
          //   bool isRefreshed = await _refreshToken();
          //   if (isRefreshed) {
          //     return handler.resolve(await dio.request(e.requestOptions.path));
          //   }
          // }
          return handler.next(e);
        },
      ),
    );
  }
}
