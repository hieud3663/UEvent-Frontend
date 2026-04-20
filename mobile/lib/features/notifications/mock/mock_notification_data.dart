import 'package:frontend/features/notifications/models/notification_model.dart';

class MockNotificationData {
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif-001',
      title: 'Sự kiện sắp diễn ra!',
      message: 'Sự kiện "UEvent Launch Party 2026" sẽ bắt đầu sau 24 giờ nữa.',
      type: NotificationType.reminder,
      deliveredAt: DateTime.now().subtract(const Duration(minutes: 30)),
      eventId: 'event-001',
    ),
    NotificationModel(
      id: 'notif-002',
      title: 'Xác nhận đăng ký',
      message: 'Bạn đã đăng ký thành công sự kiện. Quét mã QR tại cổng để vào cửa.',
      type: NotificationType.ticketConfirm,
      deliveredAt: DateTime.now().subtract(const Duration(days: 2)),
      readAt: DateTime.now().subtract(const Duration(days: 1)),
      eventId: 'event-001',
    ),
  ];
}
