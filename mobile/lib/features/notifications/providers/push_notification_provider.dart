import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/controller/push_notification_controller.dart';

final pushNotificationControllerProvider =
    AsyncNotifierProvider<PushNotificationController, void>(
      PushNotificationController.new,
    );
