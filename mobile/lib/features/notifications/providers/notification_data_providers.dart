import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/notifications/repositories/notification_repository.dart';
import 'package:frontend/features/notifications/services/notification_service.dart';
import 'package:frontend/features/notifications/services/push_notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.read(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.read(notificationServiceProvider)),
);

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(),
);
