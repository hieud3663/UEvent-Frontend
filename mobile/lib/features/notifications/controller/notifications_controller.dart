import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/providers/notification_data_providers.dart';

class NotificationsController extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return _fetchNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchNotifications);
  }

  Future<void> refreshSilently() async {
    final previousState = state;
    final nextState = await AsyncValue.guard(_fetchNotifications);

    if (nextState.hasError) {
      state = previousState;
      return;
    }

    state = nextState;
  }

  Future<void> markAsRead(String id) async {
    final previousState = state;

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(id);
      state = await AsyncValue.guard(_fetchNotifications);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<List<NotificationModel>> _fetchNotifications() {
    final repository = ref.read(notificationRepositoryProvider);
    return repository.getNotifications();
  }
}
