import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/notifications/dtos/notification_dto.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationDto>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get('/notifications');
      return mapListData(response.data, NotificationDtoMapper.fromMap);
    } on DioException {
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.post('/notifications/$id/read');
    } on DioException {
      rethrow;
    }
  }
}