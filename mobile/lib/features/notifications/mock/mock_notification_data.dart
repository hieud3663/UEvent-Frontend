import 'package:frontend/features/notifications/models/notification_model.dart';

class MockNotificationData {
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif-001',
      title: 'Sự kiện sắp diễn ra!',
      description: 'Sự kiện "UEvent Launch Party 2026" sẽ bắt đầu sau 24 giờ nữa.',
      isRead: false,
      type: NotificationType.reminder,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      relatedEventId: 'event-001',
    ),
    NotificationModel(
      id: 'notif-002',
      title: 'Xác nhận đăng ký',
      description: 'Bạn đã đăng ký thành công sự kiện. Quét mã QR tại cổng để vào cửa.',
      isRead: true,
      type: NotificationType.ticketConfirm,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      relatedEventId: 'event-001',
    ),
  ];
}
