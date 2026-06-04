import 'dart:convert';

import 'package:frontend/features/notifications/models/notification_model.dart';

enum NotificationTarget {
  eventUser,
  eventOrganizer,
  ticket,
  organizerRegistrations,
  organizerQuestions,
  questionDetail,
  profile,
  notificationDetail,
}

class NotificationIntent {
  final String? recipientId;
  final String? notificationId;
  final String type;
  final String category;
  final NotificationTarget target;
  final String? eventId;
  final String? registrationId;
  final String? ticketId;
  final String? questionId;
  final String? roleHint;
  final String? actionRoute;
  final NotificationModel? notification;

  const NotificationIntent({
    this.recipientId,
    this.notificationId,
    required this.type,
    required this.category,
    required this.target,
    this.eventId,
    this.registrationId,
    this.ticketId,
    this.questionId,
    this.roleHint,
    this.actionRoute,
    this.notification,
  });

  factory NotificationIntent.fromNotificationModel(
    NotificationModel notification,
  ) {
    return NotificationIntent(
      recipientId: notification.recipientId ?? notification.id,
      notificationId: notification.notificationId,
      type: notification.type.name,
      category: notification.category,
      target: _parseTarget(notification.target),
      eventId: notification.eventId,
      registrationId: notification.registrationId,
      ticketId: notification.ticketId,
      questionId: notification.questionId,
      roleHint: notification.roleHint,
      actionRoute: notification.actionRoute,
      notification: notification,
    )._withRouteFallbacks();
  }

  factory NotificationIntent.fromRemoteMessageData(Map<String, dynamic> data) {
    return NotificationIntent(
      recipientId: _read(data, 'recipient_id', 'recipientId', 'id'),
      notificationId: _read(data, 'notification_id', 'notificationId'),
      type: _read(data, 'type') ?? 'announcement',
      category: _read(data, 'category') ?? 'system',
      target: _parseTarget(_read(data, 'target')),
      eventId: _read(data, 'event_id', 'eventId'),
      registrationId: _read(data, 'registration_id', 'registrationId'),
      ticketId: _read(data, 'ticket_id', 'ticketId'),
      questionId: _read(data, 'question_id', 'questionId'),
      roleHint: _read(data, 'role_hint', 'roleHint'),
      actionRoute: _read(data, 'action_route', 'actionRoute', 'deep_link'),
    )._withRouteFallbacks();
  }

  factory NotificationIntent.fromLocalPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const NotificationIntent(
        type: 'announcement',
        category: 'system',
        target: NotificationTarget.notificationDetail,
      );
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return NotificationIntent.fromRemoteMessageData(decoded);
      }
    } catch (_) {
      return NotificationIntent(
        notificationId: payload,
        type: 'announcement',
        category: 'system',
        target: NotificationTarget.notificationDetail,
      );
    }
    return const NotificationIntent(
      type: 'announcement',
      category: 'system',
      target: NotificationTarget.notificationDetail,
    );
  }

  String get dispatchKey {
    return [
      recipientId,
      notificationId,
      target.name,
      eventId,
      registrationId,
      ticketId,
      questionId,
    ].whereType<String>().join(':');
  }

  NotificationIntent _withRouteFallbacks() {
    final route = actionRoute?.trim();
    if (route == null || route.isEmpty) return this;
    final uri = Uri.tryParse(route);
    final params = uri?.queryParameters ?? const <String, String>{};

    return NotificationIntent(
      recipientId: recipientId,
      notificationId: notificationId,
      type: type,
      category: category,
      target: target,
      eventId: eventId ?? params['event_id'] ?? params['eventId'],
      registrationId:
          registrationId ??
          params['registration_id'] ??
          params['registrationId'],
      ticketId: ticketId ?? params['ticket_id'] ?? params['ticketId'],
      questionId: questionId ?? params['question_id'] ?? params['questionId'],
      roleHint: roleHint,
      actionRoute: actionRoute,
      notification: notification,
    );
  }

  static String? _read(
    Map<String, dynamic> data,
    String key, [
    String? alt1,
    String? alt2,
  ]) {
    final value =
        data[key] ??
        (alt1 == null ? null : data[alt1]) ??
        (alt2 == null ? null : data[alt2]);
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static NotificationTarget _parseTarget(String? rawTarget) {
    switch (rawTarget?.trim()) {
      case 'event_user':
      case 'eventUser':
        return NotificationTarget.eventUser;
      case 'event_organizer':
      case 'eventOrganizer':
        return NotificationTarget.eventOrganizer;
      case 'ticket':
        return NotificationTarget.ticket;
      case 'organizer_registrations':
      case 'organizerRegistrations':
        return NotificationTarget.organizerRegistrations;
      case 'organizer_questions':
      case 'organizerQuestions':
        return NotificationTarget.organizerQuestions;
      case 'question_detail':
      case 'questionDetail':
        return NotificationTarget.questionDetail;
      case 'profile':
        return NotificationTarget.profile;
      case 'notification_detail':
      case 'notificationDetail':
      default:
        return NotificationTarget.notificationDetail;
    }
  }
}
