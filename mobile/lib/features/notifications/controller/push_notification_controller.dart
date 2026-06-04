import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/app_setting/models/app_setting_key.dart';
import 'package:frontend/features/app_setting/models/app_setting_state.dart';
import 'package:frontend/features/app_setting/providers/app_setting_providers.dart';
import 'package:frontend/features/notifications/models/notification_category.dart';
import 'package:frontend/features/notifications/models/notification_intent.dart';
import 'package:frontend/features/notifications/providers/notification_data_providers.dart';
import 'package:frontend/features/notifications/providers/notification_intent_provider.dart';
import 'package:frontend/features/notifications/providers/notifications_controller_provider.dart';

class PushNotificationController extends AsyncNotifier<void> {
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription? _foregroundMessageSubscription;
  StreamSubscription? _openedMessageSubscription;
  StreamSubscription? _localNotificationTapSubscription;
  DateTime? _lastRefreshAt;
  String? _currentToken;

  @override
  Future<void> build() async {
    ref.listen<AsyncValue<AppSettingState>>(appSettingControllerProvider, (
      previous,
      next,
    ) {
      final settings = next.value;
      if (settings == null) return;
      unawaited(_syncNotificationPreferences(settings, suppressErrors: true));
    });
    ref.onDispose(() {
      _tokenRefreshSubscription?.cancel();
      _foregroundMessageSubscription?.cancel();
      _openedMessageSubscription?.cancel();
      _localNotificationTapSubscription?.cancel();
    });
  }

  Future<void> registerCurrentDevice() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = ref.read(appSettingControllerProvider).value;
      if (settings != null) {
        await _syncNotificationPreferences(settings);
      }
      if (!_pushNotificationsEnabled()) return;

      final pushService = ref.read(pushNotificationServiceProvider);
      final repository = ref.read(notificationRepositoryProvider);
      final token = await pushService.requestToken();
      _listenForMessages();

      if (token == null || token.isEmpty) {
        return;
      }

      _currentToken = token;
      await repository.registerDevice(
        fcmToken: token,
        deviceName: 'Ứng dụng UEvent',
      );
      if (settings != null) {
        await _syncNotificationPreferences(settings);
      }
      _listenForTokenRefresh();
    });
  }

  Future<void> unregisterCurrentDevice() async {
    final settings = ref.read(appSettingControllerProvider).value;
    if (settings != null) {
      await _syncNotificationPreferences(settings);
    }

    final token = _currentToken;
    if (token == null || token.isEmpty) return;

    final repository = ref.read(notificationRepositoryProvider);
    await repository.unregisterDevice(token);
    _currentToken = null;
  }

  void _listenForTokenRefresh() {
    _tokenRefreshSubscription ??= ref
        .read(pushNotificationServiceProvider)
        .onTokenRefresh
        .listen((token) async {
          if (!_pushNotificationsEnabled()) return;

          _currentToken = token;
          final settings = ref.read(appSettingControllerProvider).value;
          if (settings != null) {
            await _syncNotificationPreferences(settings);
          }
          await ref
              .read(notificationRepositoryProvider)
              .registerDevice(fcmToken: token, deviceName: 'Ứng dụng UEvent');
        });
  }

  Future<void> _syncNotificationPreferences(
    AppSettingState settings, {
    bool suppressErrors = false,
  }) async {
    try {
      await ref
          .read(notificationRepositoryProvider)
          .updatePreferences(_notificationPreferencePayload(settings));
    } catch (_) {
      if (!suppressErrors) rethrow;
    }
  }

  Map<String, Object?> _notificationPreferencePayload(
    AppSettingState settings,
  ) {
    return {
      'push_enabled': settings.boolValue(
        AppSettingKey.notificationPushEnabled,
        fallback: true,
      ),
      'event_reminders_enabled': settings.boolValue(
        AppSettingKey.notificationEventRemindersEnabled,
        fallback: true,
      ),
      'ticket_updates_enabled': settings.boolValue(
        AppSettingKey.notificationTicketUpdatesEnabled,
        fallback: true,
      ),
      'organizer_updates_enabled': settings.boolValue(
        AppSettingKey.notificationOrganizerUpdatesEnabled,
        fallback: true,
      ),
      'marketing_enabled': settings.boolValue(
        AppSettingKey.notificationMarketingEnabled,
      ),
      'quiet_hours_enabled': settings.boolValue(
        AppSettingKey.notificationQuietHoursEnabled,
      ),
      'quiet_hours_start': settings.stringValue(
        AppSettingKey.notificationQuietHoursStart,
        fallback: '22:00',
      ),
      'quiet_hours_end': settings.stringValue(
        AppSettingKey.notificationQuietHoursEnd,
        fallback: '07:00',
      ),
      'timezone': 'Asia/Bangkok',
    };
  }

  void _listenForMessages() {
    final pushService = ref.read(pushNotificationServiceProvider);
    _foregroundMessageSubscription ??= pushService.onForegroundMessage.listen((
      message,
    ) async {
      if (_shouldShowForegroundNotification(message)) {
        await pushService.showForegroundNotification(message);
      }
      await _refreshNotifications();
    });
    _openedMessageSubscription ??= pushService.onNotificationOpenedApp.listen((
      message,
    ) async {
      _queueIntent(NotificationIntent.fromRemoteMessageData(message.data));
      await _refreshNotifications(force: true);
    });
    _localNotificationTapSubscription ??= pushService.onLocalNotificationTap
        .listen((payload) async {
          _queueIntent(NotificationIntent.fromLocalPayload(payload));
          await _refreshNotifications(force: true);
        });
    unawaited(
      pushService.getInitialMessage().then((message) {
        if (message != null) {
          _queueIntent(NotificationIntent.fromRemoteMessageData(message.data));
          return _refreshNotifications(force: true);
        }
        return null;
      }),
    );
    unawaited(
      pushService.getInitialLocalNotificationPayload().then((payload) {
        if (payload != null) {
          _queueIntent(NotificationIntent.fromLocalPayload(payload));
          return _refreshNotifications(force: true);
        }
        return null;
      }),
    );
  }

  void _queueIntent(NotificationIntent intent) {
    ref.read(notificationIntentControllerProvider.notifier).queue(intent);
  }

  Future<void> _refreshNotifications({bool force = false}) async {
    final now = DateTime.now();
    final lastRefreshAt = _lastRefreshAt;
    if (!force &&
        lastRefreshAt != null &&
        now.difference(lastRefreshAt).inMilliseconds < 800) {
      return;
    }
    _lastRefreshAt = now;

    try {
      await ref
          .read(notificationsControllerProvider.notifier)
          .refreshSilently();
    } catch (_) {}
  }

  bool _pushNotificationsEnabled() {
    return ref
            .read(appSettingControllerProvider)
            .value
            ?.boolValue(
              AppSettingKey.notificationPushEnabled,
              fallback: true,
            ) ??
        true;
  }

  bool _shouldShowForegroundNotification(RemoteMessage message) {
    final settings = ref.read(appSettingControllerProvider).value;
    if (settings == null) return true;
    if (!settings.boolValue(
      AppSettingKey.notificationPushEnabled,
      fallback: true,
    )) {
      return false;
    }
    if (settings.isQuietHoursActive) return false;

    return switch (NotificationCategory.fromPayload(message.data)) {
      NotificationCategory.ticket => settings.boolValue(
        AppSettingKey.notificationTicketUpdatesEnabled,
        fallback: true,
      ),
      NotificationCategory.organizer => settings.boolValue(
        AppSettingKey.notificationOrganizerUpdatesEnabled,
        fallback: true,
      ),
      NotificationCategory.marketing => settings.boolValue(
        AppSettingKey.notificationMarketingEnabled,
      ),
      NotificationCategory.event => settings.boolValue(
        AppSettingKey.notificationEventRemindersEnabled,
        fallback: true,
      ),
      NotificationCategory.unknown => true,
    };
  }
}
