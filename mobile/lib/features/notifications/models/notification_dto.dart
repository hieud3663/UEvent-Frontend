import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

@freezed
class NotificationDTO with _$NotificationDTO {
  const factory NotificationDTO({
    required String id,
    required String title,
    required String message,
    required bool isRead,
    required String type, // 'event_reminder', 'system', 'ticket_update'
    required DateTime createdAt,
    String? relatedEventId,
  }) = _NotificationDTO;

  factory NotificationDTO.fromJson(Map<String, dynamic> json) =>
      _$NotificationDTOFromJson(json);
}
