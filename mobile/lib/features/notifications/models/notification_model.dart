// File: lib/models/notification_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Data class representing a Notification item.
@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationModel {
  final String id;
  final String? eventId;
  final String title;
  final String message;
  @JsonKey(unknownEnumValue: NotificationType.announcement)
  final NotificationType type;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final String? actionLabel;
  final String? actionRoute;

  const NotificationModel({
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

  String get description => message;

  DateTime get timestamp => deliveredAt ?? readAt ?? DateTime.now();

  bool get isRead => readAt != null;

  String? get relatedEventId => eventId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

enum NotificationType { eventInvite, announcement, reminder, ticketConfirm }
