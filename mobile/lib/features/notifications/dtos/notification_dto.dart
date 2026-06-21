import 'package:dart_mappable/dart_mappable.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';

part 'notification_dto.mapper.dart';

@MappableClass()
class NotificationDto with NotificationDtoMappable {
  final String id;
  @MappableField(key: 'recipient_id')
  final String? recipientId;
  @MappableField(key: 'notification_id')
  final String? notificationId;
  @MappableField(key: 'event_id')
  final String? eventId;
  @MappableField(key: 'registration_id')
  final String? registrationId;
  @MappableField(key: 'ticket_id')
  final String? ticketId;
  @MappableField(key: 'question_id')
  final String? questionId;
  final String title;
  final String message;
  final String type;
  final String? category;
  final String? target;
  @MappableField(key: 'role_hint')
  final String? roleHint;
  @MappableField(key: 'read_at')
  final DateTime? readAt;
  @MappableField(key: 'delivered_at')
  final DateTime? deliveredAt;
  @MappableField(key: 'opened_at')
  final DateTime? openedAt;
  @MappableField(key: 'action_label')
  final String? actionLabel;
  @MappableField(key: 'action_route')
  final String? actionRoute;

  const NotificationDto({
    required this.id,
    this.recipientId,
    this.notificationId,
    this.eventId,
    this.registrationId,
    this.ticketId,
    this.questionId,
    required this.title,
    required this.message,
    required this.type,
    this.category,
    this.target,
    this.roleHint,
    this.readAt,
    this.deliveredAt,
    this.openedAt,
    this.actionLabel,
    this.actionRoute,
  });
}

extension NotificationDtoMapping on NotificationDto {
  NotificationModel toModel() {
    return NotificationModel(
      id: id,
      recipientId: recipientId ?? id,
      notificationId: notificationId,
      eventId: eventId,
      registrationId: registrationId,
      ticketId: ticketId,
      questionId: questionId,
      title: title,
      message: message,
      type: _toNotificationType(type),
      category: category ?? 'system',
      target: target ?? 'notification_detail',
      roleHint: roleHint,
      readAt: readAt,
      deliveredAt: deliveredAt,
      openedAt: openedAt,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }

  NotificationType _toNotificationType(String rawType) {
    switch (rawType) {
      case 'invite':
      case 'event_invite':
        return NotificationType.eventInvite;
      case 'event_update':
        return NotificationType.eventUpdate;
      case 'reminder':
        return NotificationType.reminder;
      case 'announcement':
        return NotificationType.announcement;
      case 'alert':
        return NotificationType.alert;
      case 'promotion':
        return NotificationType.promotion;
      case 'ticket_confirm':
        return NotificationType.ticketConfirm;
      case 'registration_confirmed':
        return NotificationType.registrationConfirmed;
      case 'registration_waitlisted':
        return NotificationType.registrationWaitlisted;
      case 'new_registration':
        return NotificationType.newRegistration;
      case 'organizer_announcement':
        return NotificationType.organizerAnnouncement;
      case 'question_answered':
        return NotificationType.questionAnswered;
      case 'organizer_request_approved':
        return NotificationType.organizerRequestApproved;
      case 'organizer_request_rejected':
        return NotificationType.organizerRequestRejected;
      default:
        return NotificationType.announcement;
    }
  }
}
