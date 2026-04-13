import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.getNotifications();
});
