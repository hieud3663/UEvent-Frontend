import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/mock/mock_user_data.dart';
import 'package:frontend/features/auth/models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponseModel> login(String email, String password) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      return MockUserData.mockAuthResponse;
    }

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  Future<UserModel> getProfile() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockUserData.currentUser;
    }

    try {
      final response = await _apiClient.dio.get('/auth/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }
}
