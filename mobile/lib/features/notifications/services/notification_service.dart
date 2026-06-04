import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/notifications/dtos/notification_dto.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationDto>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/notifications/');
      return mapListData(response.data, NotificationDtoMapper.fromMap);
    } on DioException {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count/');
      final data = extractObjectData(response.data);
      return (data['unread_count'] as num?)?.toInt() ?? 0;
    } on DioException {
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.post('/notifications/$id/read/');
    } on DioException {
      rethrow;
    }
  }

  Future<void> markAsOpened(String id) async {
    try {
      await _apiClient.dio.post('/notifications/$id/opened/');
    } on DioException {
      rethrow;
    }
  }

  Future<void> registerDevice({
    required String fcmToken,
    String? deviceName,
  }) async {
    try {
      await _apiClient.dio.post(
        '/notifications/register-device/',
        data: {
          'fcm_token': fcmToken,
          if (deviceName != null && deviceName.isNotEmpty)
            'device_name': deviceName,
        },
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> unregisterDevice(String fcmToken) async {
    try {
      await _apiClient.dio.post(
        '/notifications/unregister-device/',
        data: {'fcm_token': fcmToken},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> updatePreferences(Map<String, Object?> preferences) async {
    try {
      await _apiClient.dio.patch(
        '/notifications/preferences/',
        data: preferences,
      );
    } on DioException {
      rethrow;
    }
  }
}
