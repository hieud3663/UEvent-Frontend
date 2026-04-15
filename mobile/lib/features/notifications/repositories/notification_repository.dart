import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/features/notifications/dtos/notification_dto.dart';
import 'package:frontend/features/notifications/mock/mock_notification_data.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/services/notification_service.dart';

abstract interface class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service;

  NotificationRepositoryImpl(this._service);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockNotificationData.notifications;
    }

    final dtos = await _service.getNotifications();
    return dtos.map((dto) => dto.toModel()).toList(growable: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _service.markAsRead(id);
  }
}
