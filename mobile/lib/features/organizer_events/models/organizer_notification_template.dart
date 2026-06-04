import 'package:flutter/material.dart';

class OrganizerNotificationTemplate {
  final String id;
  final IconData icon;
  final String title;
  final String message;
  final String badge;

  const OrganizerNotificationTemplate({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.badge,
  });

  String resolveTitle(String eventTitle) => _resolve(title, eventTitle);

  String resolveMessage(String eventTitle) => _resolve(message, eventTitle);

  String _resolve(String value, String eventTitle) {
    final normalizedTitle = eventTitle.trim().isEmpty
        ? 'sự kiện'
        : eventTitle.trim();
    return value.replaceAll('{event}', normalizedTitle);
  }
}

const organizerNotificationTemplates = [
  OrganizerNotificationTemplate(
    id: 'event_reminder',
    icon: Icons.schedule,
    title: 'Sắp diễn ra: {event}',
    message:
        'Sự kiện {event} sắp diễn ra. Vui lòng kiểm tra vé và đến đúng giờ.',
    badge: 'Nhắc lịch',
  ),
  OrganizerNotificationTemplate(
    id: 'check_in_ready',
    icon: Icons.qr_code_scanner,
    title: 'Check-in đã sẵn sàng',
    message:
        'Check-in cho {event} đã sẵn sàng. Hãy chuẩn bị mã QR để vào khu vực sự kiện.',
    badge: 'Check-in',
  ),
  OrganizerNotificationTemplate(
    id: 'venue_update',
    icon: Icons.location_on_outlined,
    title: 'Cập nhật địa điểm sự kiện',
    message:
        'BTC đã cập nhật thông tin địa điểm cho {event}. Vui lòng mở chi tiết sự kiện để kiểm tra trước khi đến.',
    badge: 'Địa điểm',
  ),
  OrganizerNotificationTemplate(
    id: 'qa_open',
    icon: Icons.forum_outlined,
    title: 'Khu vực hỏi đáp đã mở',
    message:
        'Bạn có thể gửi câu hỏi cho BTC trong trang chi tiết của {event}. BTC sẽ phản hồi trong thời gian sớm nhất.',
    badge: 'Hỏi đáp',
  ),
  OrganizerNotificationTemplate(
    id: 'thank_you',
    icon: Icons.favorite_border,
    title: 'Cảm ơn bạn đã tham gia',
    message:
        'Cảm ơn bạn đã tham gia {event}. BTC rất mong nhận được phản hồi của bạn để cải thiện các sự kiện tiếp theo.',
    badge: 'Sau sự kiện',
  ),
];
