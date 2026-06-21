// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String?,
      notificationId: json['notification_id'] as String?,
      eventId: json['event_id'] as String?,
      registrationId: json['registration_id'] as String?,
      ticketId: json['ticket_id'] as String?,
      questionId: json['question_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecode(
        _$NotificationTypeEnumMap,
        json['type'],
        unknownValue: NotificationType.announcement,
      ),
      category: json['category'] as String? ?? 'system',
      target: json['target'] as String? ?? 'notification_detail',
      roleHint: json['role_hint'] as String?,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      openedAt: json['opened_at'] == null
          ? null
          : DateTime.parse(json['opened_at'] as String),
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient_id': instance.recipientId,
      'notification_id': instance.notificationId,
      'event_id': instance.eventId,
      'registration_id': instance.registrationId,
      'ticket_id': instance.ticketId,
      'question_id': instance.questionId,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'category': instance.category,
      'target': instance.target,
      'role_hint': instance.roleHint,
      'read_at': instance.readAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'opened_at': instance.openedAt?.toIso8601String(),
      'action_label': instance.actionLabel,
      'action_route': instance.actionRoute,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.announcement: 'announcement',
  NotificationType.alert: 'alert',
  NotificationType.reminder: 'reminder',
  NotificationType.promotion: 'promotion',
  NotificationType.eventInvite: 'invite',
  NotificationType.ticketConfirm: 'ticket_confirm',
  NotificationType.registrationConfirmed: 'registration_confirmed',
  NotificationType.registrationWaitlisted: 'registration_waitlisted',
  NotificationType.newRegistration: 'new_registration',
  NotificationType.organizerAnnouncement: 'organizer_announcement',
  NotificationType.questionAnswered: 'question_answered',
  NotificationType.organizerRequestApproved: 'organizer_request_approved',
  NotificationType.organizerRequestRejected: 'organizer_request_rejected',
  NotificationType.eventUpdate: 'event_update',
};
