import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/auth/mock/mock_user_data.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/models/avatar_upload_model.dart';
import 'package:frontend/features/profile/models/organizer_request_model.dart';

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
      final current = MockUserData.currentUser;
      return UserModel(
        id: current.id,
        email: current.email,
        fullName: updateData['full_name']?.toString() ?? current.fullName,
        accountStatus: current.accountStatus,
        primaryRole: current.primaryRole,
        isProfileComplete: current.isProfileComplete,
        phoneNumber:
            updateData['phone_number']?.toString() ?? current.phoneNumber,
        studentCode:
            updateData['student_code']?.toString() ?? current.studentCode,
        faculty: updateData['faculty']?.toString() ?? current.faculty,
        className: updateData['class_name']?.toString() ?? current.className,
        avatarUrl: updateData.containsKey('avatar_image_key')
            ? 'https://i.pravatar.cc/300?img=12'
            : current.avatarUrl,
      );
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

  Future<AvatarUploadModel> getAvatarPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const AvatarUploadModel(
        objectKey: 'users/mock/avatars/avatar.png',
        presignedUrl: 'https://example.com/mock-avatar-upload-url',
        method: 'PUT',
        expiresIn: 900,
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/auth/profile/avatar/presigned-url/',
        data: {'file_name': fileName, 'content_type': contentType},
      );
      return AvatarUploadModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> uploadAvatarImage({
    required File imageFile,
    required String presignedUrl,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return;
    }

    final uploadClient = Dio();
    final bytes = await imageFile.readAsBytes();

    try {
      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: presignedUrl,
        bytes: bytes,
        contentType: contentType,
      );
    } on DioException catch (error) {
      final redirectUrl = _s3TemporaryRedirectUrl(error, presignedUrl);
      if (redirectUrl == null) rethrow;

      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: redirectUrl,
        bytes: bytes,
        contentType: contentType,
      );
    }
  }

  Future<List<OrganizerRequestModel>> getMyOrganizerRequests() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const [];
    }

    try {
      final response = await _apiClient.dio.get('/organizer-requests/');
      return extractListData(
        response.data,
      ).map(OrganizerRequestModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<AvatarUploadModel> getOrganizerRequestProofPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const AvatarUploadModel(
        objectKey: 'users/mock/organizer-proofs/proof.jpg',
        presignedUrl: 'https://example.com/mock-organizer-proof-upload-url',
        method: 'PUT',
        expiresIn: 900,
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/organizer-requests/proof-upload-url/',
        data: {'file_name': fileName, 'content_type': contentType},
      );
      return AvatarUploadModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> uploadOrganizerRequestProof({
    required File proofFile,
    required String presignedUrl,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return;
    }

    final uploadClient = Dio();
    final bytes = await proofFile.readAsBytes();

    try {
      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: presignedUrl,
        bytes: bytes,
        contentType: contentType,
      );
    } on DioException catch (error) {
      final redirectUrl = _s3TemporaryRedirectUrl(error, presignedUrl);
      if (redirectUrl == null) rethrow;

      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: redirectUrl,
        bytes: bytes,
        contentType: contentType,
      );
    }
  }

  Future<OrganizerRequestModel> createOrganizerRequest({
    required String reason,
    required String proofFileKey,
    required String proofFileName,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return OrganizerRequestModel(
        id: 'mock-organizer-request',
        status: 'pending',
        reason: reason,
        proofFileName: proofFileName,
        proofFileUrl: '',
        reviewNote: '',
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/organizer-requests/',
        data: {
          'reason': reason,
          'proof_file_key': proofFileKey,
          'proof_file_name': proofFileName,
        },
      );
      return OrganizerRequestModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> _putPresignedObject({
    required Dio uploadClient,
    required String presignedUrl,
    required List<int> bytes,
    required String contentType,
  }) {
    return uploadClient.put<void>(
      presignedUrl,
      data: bytes,
      options: Options(
        contentType: contentType,
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
        responseType: ResponseType.plain,
      ),
    );
  }

  String? _s3TemporaryRedirectUrl(DioException error, String originalUrl) {
    if (error.response?.statusCode != 307) return null;

    final responseBody = error.response?.data?.toString();
    if (responseBody == null) return null;

    final endpointMatch = RegExp(
      r'<Endpoint>([^<]+)</Endpoint>',
    ).firstMatch(responseBody);
    final endpoint = endpointMatch?.group(1);
    if (endpoint == null || endpoint.isEmpty) return null;

    final originalUri = Uri.parse(originalUrl);
    return originalUri.replace(host: endpoint).toString();
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
