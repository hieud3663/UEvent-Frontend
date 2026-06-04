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
    ref.invalidate(notificationUnreadCountProvider);
  }

  Future<void> refreshSilently() async {
    final previousState = state;
    final nextState = await AsyncValue.guard(_fetchNotifications);

    if (nextState.hasError) {
      state = previousState;
      return;
    }

    state = nextState;
    ref.invalidate(notificationUnreadCountProvider);
  }

  Future<void> markAsRead(String id) async {
    final previousState = state;

    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(id);
      state = await AsyncValue.guard(_fetchNotifications);
      ref.invalidate(notificationUnreadCountProvider);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<int> markVisibleAsRead(
    Iterable<NotificationModel> notifications,
  ) async {
    final unreadNotifications = notifications
        .where((notification) => !notification.isRead)
        .toList(growable: false);

    if (unreadNotifications.isEmpty) return 0;

    final previousState = state;

    try {
      final repository = ref.read(notificationRepositoryProvider);
      for (final notification in unreadNotifications) {
        await repository.markAsRead(notification.id);
      }
      state = await AsyncValue.guard(_fetchNotifications);
      ref.invalidate(notificationUnreadCountProvider);
      return unreadNotifications.length;
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
