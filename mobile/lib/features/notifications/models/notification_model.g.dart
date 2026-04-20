// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecode(
        _$NotificationTypeEnumMap,
        json['type'],
        unknownValue: NotificationType.announcement,
      ),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'title': instance.title,
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'read_at': instance.readAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'action_label': instance.actionLabel,
      'action_route': instance.actionRoute,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.eventInvite: 'eventInvite',
  NotificationType.announcement: 'announcement',
  NotificationType.reminder: 'reminder',
  NotificationType.ticketConfirm: 'ticketConfirm',
};
