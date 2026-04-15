import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/controller/notifications_controller.dart';

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationModel>>(
      NotificationsController.new,
    );
