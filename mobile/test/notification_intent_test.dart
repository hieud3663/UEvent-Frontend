import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/notifications/models/notification_intent.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';
import 'package:frontend/features/notifications/providers/notification_intent_provider.dart';

void main() {
  test('NotificationIntent parses snake_case remote payload', () {
    final intent = NotificationIntent.fromRemoteMessageData(const {
      'recipient_id': 'recipient-1',
      'notification_id': 'notification-1',
      'type': 'registration_confirmed',
      'category': 'ticket',
      'target': 'ticket',
      'event_id': 'event-1',
      'registration_id': 'registration-1',
      'ticket_id': 'ticket-1',
      'role_hint': 'student',
    });

    expect(intent.recipientId, 'recipient-1');
    expect(intent.notificationId, 'notification-1');
    expect(intent.target, NotificationTarget.ticket);
    expect(intent.eventId, 'event-1');
    expect(intent.registrationId, 'registration-1');
    expect(intent.ticketId, 'ticket-1');
    expect(intent.roleHint, 'student');
  });

  test(
    'NotificationIntent parses camelCase aliases and action route fallback',
    () {
      final intent = NotificationIntent.fromRemoteMessageData(const {
        'recipientId': 'recipient-2',
        'notificationId': 'notification-2',
        'target': 'eventOrganizer',
        'actionRoute':
            'uevent://notifications/open?target=event_organizer&event_id=event-2',
      });

      expect(intent.recipientId, 'recipient-2');
      expect(intent.notificationId, 'notification-2');
      expect(intent.target, NotificationTarget.eventOrganizer);
      expect(intent.eventId, 'event-2');
    },
  );

  test(
    'NotificationIntent falls back unknown target to notification detail',
    () {
      final intent = NotificationIntent.fromRemoteMessageData(const {
        'target': 'unsupported_target',
      });

      expect(intent.target, NotificationTarget.notificationDetail);
    },
  );

  test('NotificationIntent builds from inbox notification model', () {
    const notification = NotificationModel(
      id: 'recipient-3',
      notificationId: 'notification-3',
      eventId: 'event-3',
      title: 'Tin mới',
      message: 'Nội dung',
      type: NotificationType.announcement,
      category: 'event',
      target: 'event_user',
    );

    final intent = NotificationIntent.fromNotificationModel(notification);

    expect(intent.recipientId, 'recipient-3');
    expect(intent.notificationId, 'notification-3');
    expect(intent.eventId, 'event-3');
    expect(intent.target, NotificationTarget.eventUser);
  });

  test('NotificationIntent parses full local notification JSON payload', () {
    final payload = jsonEncode({
      'recipient_id': 'recipient-4',
      'notification_id': 'notification-4',
      'target': 'organizer_registrations',
      'event_id': 'event-4',
      'role_hint': 'organizer',
    });

    final intent = NotificationIntent.fromLocalPayload(payload);

    expect(intent.recipientId, 'recipient-4');
    expect(intent.notificationId, 'notification-4');
    expect(intent.target, NotificationTarget.organizerRegistrations);
    expect(intent.eventId, 'event-4');
    expect(intent.roleHint, 'organizer');
  });

  test('NotificationIntentController ignores duplicate consumed intent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const intent = NotificationIntent(
      recipientId: 'recipient-5',
      notificationId: 'notification-5',
      type: 'announcement',
      category: 'event',
      target: NotificationTarget.eventUser,
      eventId: 'event-5',
    );

    final controller = container.read(
      notificationIntentControllerProvider.notifier,
    );
    controller.queue(intent);
    expect(container.read(notificationIntentControllerProvider), intent);
    expect(controller.consume(), intent);

    controller.queue(intent);
    expect(container.read(notificationIntentControllerProvider), isNull);
  });
}
