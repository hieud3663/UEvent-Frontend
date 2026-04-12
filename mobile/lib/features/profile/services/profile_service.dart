import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/mock/mock_user_data.dart';
import 'package:frontend/features/auth/models/user_dto.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserDTO> getMyProfile() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return MockUserData.currentUser;
    }

    try {
      final response = await _apiClient.dio.get('/auth/profile');
      return UserDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get profile: \${e.message}');
    }
  }

  Future<UserDTO> updateProfile(Map<String, dynamic> updateData) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      // Just return the same for mock purposes
      return MockUserData.currentUser;
    }

    try {
      final response = await _apiClient.dio.patch('/auth/profile', data: updateData);
      return UserDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: \${e.message}');
    }
  }
}
