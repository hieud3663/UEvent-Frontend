import 'package:frontend/features/notifications/models/notification_dto.dart';

class MockNotificationData {
  static final List<NotificationDTO> notifications = [
    NotificationDTO(
      id: 'notif-001',
      title: 'Sự kiện sắp diễn ra!',
      message: 'Sự kiện "UEvent Launch Party 2026" sẽ bắt đầu sau 24 giờ nữa.',
      isRead: false,
      type: 'event_reminder',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      relatedEventId: 'event-001',
    ),
    NotificationDTO(
      id: 'notif-002',
      title: 'Xác nhận đăng ký',
      message: 'Bạn đã đăng ký thành công sự kiện. Quét mã QR tại cổng để vào cửa.',
      isRead: true,
      type: 'ticket_update',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      relatedEventId: 'event-001',
    ),
  ];
}
