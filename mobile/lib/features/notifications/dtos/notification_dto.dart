import 'package:dart_mappable/dart_mappable.dart';
import 'package:frontend/features/notifications/models/notification_model.dart';

part 'notification_dto.mapper.dart';

@MappableClass()
class NotificationDto with NotificationDtoMappable {
  final String id;
  @MappableField(key: 'event_id')
  final String? eventId;
  final String title;
  final String message;
  final String type;
  @MappableField(key: 'read_at')
  final DateTime? readAt;
  @MappableField(key: 'delivered_at')
  final DateTime? deliveredAt;
  @MappableField(key: 'action_label')
  final String? actionLabel;
  @MappableField(key: 'action_route')
  final String? actionRoute;

  const NotificationDto({
    required this.id,
    this.eventId,
    required this.title,
    required this.message,
    required this.type,
    this.readAt,
    this.deliveredAt,
    this.actionLabel,
    this.actionRoute,
  });
}

extension NotificationDtoMapping on NotificationDto {
  NotificationModel toModel() {
    return NotificationModel(
      id: id,
      eventId: eventId,
      title: title,
      message: message,
      type: _toNotificationType(type),
      readAt: readAt,
      deliveredAt: deliveredAt,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }

  NotificationType _toNotificationType(String rawType) {
    switch (rawType) {
      case 'event_invite':
      case 'eventInvite':
        return NotificationType.eventInvite;
      case 'reminder':
        return NotificationType.reminder;
      case 'ticket_confirm':
      case 'ticketConfirm':
        return NotificationType.ticketConfirm;
      case 'announcement':
      default:
        return NotificationType.announcement;
    }
  }
}
