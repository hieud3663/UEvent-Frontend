import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/models/notification_intent.dart';

class NotificationIntentController extends Notifier<NotificationIntent?> {
  String? _lastConsumedKey;

  @override
  NotificationIntent? build() => null;

  void queue(NotificationIntent intent) {
    final key = intent.dispatchKey;
    if (key.isNotEmpty && key == _lastConsumedKey) return;
    state = intent;
  }

  NotificationIntent? consume() {
    final intent = state;
    if (intent == null) return null;

    final key = intent.dispatchKey;
    if (key.isNotEmpty) {
      _lastConsumedKey = key;
    }
    state = null;
    return intent;
  }
}
