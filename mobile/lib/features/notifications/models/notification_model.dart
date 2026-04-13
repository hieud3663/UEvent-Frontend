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
  final bool isRead;
  final String? relatedEventId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.actionLabel,
    this.actionRoute,
    this.isRead = false,
    this.relatedEventId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? json['message'] ?? '') as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      timestamp: DateTime.tryParse((json['timestamp'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      relatedEventId: json['relatedEventId'] as String?,
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
      'isRead': isRead,
      'relatedEventId': relatedEventId,
    };
  }
}

enum NotificationType {
  eventInvite,
  announcement,
  reminder,
  ticketConfirm,
}
