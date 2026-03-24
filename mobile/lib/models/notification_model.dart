// File: lib/models/notification_model.dart

/// Data class representing a Notification item.
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime timestamp;
  final String? actionLabel;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.actionLabel,
    this.actionRoute,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'actionLabel': actionLabel,
      'actionRoute': actionRoute,
    };
  }
}

enum NotificationType {
  eventInvite,
  announcement,
  reminder,
  ticketConfirm,
}
