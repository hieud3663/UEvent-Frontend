import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/controller/notification_intent_controller.dart';
import 'package:frontend/features/notifications/models/notification_intent.dart';

final notificationIntentControllerProvider =
    NotifierProvider<NotificationIntentController, NotificationIntent?>(
      NotificationIntentController.new,
    );
