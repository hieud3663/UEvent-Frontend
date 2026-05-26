import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/mock/mock_user_data.dart';
import 'package:frontend/features/auth/models/user_model.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserModel> getMyProfile() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return MockUserData.currentUser;
    }

    try {
      final response = await _apiClient.dio.get('/auth/profile/');
      return UserModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updateData) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      // Just return the same for mock purposes
      return MockUserData.currentUser;
    }

    try {
      final response = await _apiClient.dio.patch(
        '/auth/profile/',
        data: updateData,
      );
      return UserModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> requestEmailChangeOtp() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return;
    }

    try {
      await _apiClient.dio.post('/auth/profile/email/otp/');
    } on DioException {
      rethrow;
    }
  }

  Future<void> requestNewEmailChangeOtp({
    required String newEmail,
    required String currentOtpCode,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return;
    }

    try {
      await _apiClient.dio.post(
        '/auth/profile/email/new/otp/',
        data: {'new_email': newEmail, 'current_otp_code': currentOtpCode},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<UserModel> confirmEmailChange({
    required String newEmail,
    required String currentOtpCode,
    required String newEmailOtpCode,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 900));
      final current = MockUserData.currentUser;
      return UserModel(
        id: current.id,
        email: newEmail,
        fullName: current.fullName,
        accountStatus: current.accountStatus,
        primaryRole: current.primaryRole,
        isProfileComplete: current.isProfileComplete,
        phoneNumber: current.phoneNumber,
        studentCode: current.studentCode,
        faculty: current.faculty,
        className: current.className,
        avatarUrl: current.avatarUrl,
      );
    }

    try {
      final response = await _apiClient.dio.patch(
        '/auth/profile/email/',
        data: {
          'new_email': newEmail,
          'current_otp_code': currentOtpCode,
          'new_email_otp_code': newEmailOtpCode,
        },
      );
      return UserModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }
}
