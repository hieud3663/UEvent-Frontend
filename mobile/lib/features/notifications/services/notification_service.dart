import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/notifications/mock/mock_notification_data.dart';
import 'package:frontend/features/notifications/models/notification_dto.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationDTO>> getNotifications() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockNotificationData.notifications;
    }

    try {
      final response = await _apiClient.dio.get('/notifications');
      final List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => NotificationDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load notifications: \${e.message}');
    }
  }

  Future<void> markAsRead(String id) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    try {
      await _apiClient.dio.post('/notifications/\$id/read');
    } on DioException catch (e) {
      throw Exception('Failed to mark notification as read: \${e.message}');
    }
  }
}
