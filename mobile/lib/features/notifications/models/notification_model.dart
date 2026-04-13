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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['event_id'] ??= normalized['eventId'];
    normalized['message'] ??= normalized['description'];
    normalized['read_at'] ??= normalized['readAt'];
    normalized['delivered_at'] ??=
        normalized['deliveredAt'] ?? normalized['timestamp'] ?? normalized['createdAt'];
    normalized['action_label'] ??= normalized['actionLabel'];
    normalized['action_route'] ??= normalized['actionRoute'];

    return _$NotificationModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

enum NotificationType {
  eventInvite,
  announcement,
  reminder,
  ticketConfirm,
}
