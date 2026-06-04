import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

String formatOrganizerEventDate(DateTime value) {
  final formatted = DateFormat(
    "EEEE, dd 'tháng' MM 'năm' yyyy",
    'vi',
  ).format(value.toLocal());
  if (formatted.isEmpty) return formatted;
  return formatted.characters.first.toUpperCase() +
      formatted.characters.skip(1).join();
}

String formatOrganizerEventTimeRange(EventModel event) {
  final formatter = DateFormat('HH:mm', 'vi');
  final start = formatter.format(event.startDate.toLocal());
  final endDate = event.endDate;
  if (endDate == null) return start;

  final localEndDate = endDate.toLocal();
  final end = formatter.format(localEndDate);
  final localStartDate = event.startDate.toLocal();
  final isSameDay =
      localStartDate.year == localEndDate.year &&
      localStartDate.month == localEndDate.month &&
      localStartDate.day == localEndDate.day;

  if (isSameDay) return '$start - $end';
  return '$start - ${formatOrganizerEventDate(localEndDate)} lúc $end';
}

String organizerEventStatusLabel(EventStatus status) {
  return switch (status) {
    EventStatus.draft => 'Nháp',
    EventStatus.active => 'Đang mở',
    EventStatus.approved => 'Đã duyệt',
    EventStatus.finished => 'Đã kết thúc',
    EventStatus.cancelled => 'Đã hủy',
  };
}

String organizerRoleLabel(String role) {
  return switch (role) {
    'owner' => 'Chủ sự kiện',
    'co_host' => 'Đồng tổ chức',
    'staff' => 'Nhân sự',
    'checkin' => 'Check-in',
    _ => role.trim().isEmpty ? 'BTC' : role,
  };
}
