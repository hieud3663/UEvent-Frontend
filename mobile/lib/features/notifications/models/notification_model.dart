// File: lib/models/notification_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Data class representing a Notification item.
@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationModel {
  final String id;
  final String? recipientId;
  final String? notificationId;
  final String? eventId;
  final String? registrationId;
  final String? ticketId;
  final String? questionId;
  final String title;
  final String message;
  @JsonKey(unknownEnumValue: NotificationType.announcement)
  final NotificationType type;
  final String category;
  final String target;
  final String? roleHint;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;
  final String? actionLabel;
  final String? actionRoute;

  const NotificationModel({
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
    this.category = 'system',
    this.target = 'notification_detail',
    this.roleHint,
    this.readAt,
    this.deliveredAt,
    this.openedAt,
    this.actionLabel,
    this.actionRoute,
  });

  String get description => message;

  DateTime get timestamp => deliveredAt ?? readAt ?? DateTime.now();

  bool get isRead => readAt != null;

  String? get relatedEventId => eventId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

enum NotificationType { eventInvite, announcement, reminder, ticketConfirm }
