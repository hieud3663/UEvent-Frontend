// File: lib/mock/mock_notification_data.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Mock notification data for the Notifications screen.
class MockNotificationData {
  MockNotificationData._();

  static const List<Map<String, dynamic>> todayNotifications = [
    {
      'icon': Icons.event,
      'iconBgColor': AppColors.primaryFixed,
      'iconColor': AppColors.primary,
      'title': 'New Event Invite',
      'timestamp': '2m ago',
      'description':
          'Sarah Jenkins invited you to "Neon Nights: Underground Jazz" this Friday at 8:00 PM.',
      'actionLabel': 'Add to Calendar',
    },
    {
      'icon': Icons.campaign,
      'iconBgColor': AppColors.secondaryContainer,
      'iconColor': AppColors.secondary,
      'title': 'Venue Update',
      'timestamp': '1h ago',
      'description':
          'The workshop "Creative Coding 101" has been moved to Studio B on the 3rd floor.',
    },
  ];

  static const List<Map<String, dynamic>> yesterdayNotifications = [
    {
      'icon': Icons.alarm,
      'iconBgColor': AppColors.errorContainer,
      'iconColor': AppColors.error,
      'title': 'Upcoming Workshop',
      'timestamp': '24h ago',
      'description':
          'Reminder: "Digital Portraiture Masterclass" starts in 1 hour. Don\'t forget your tablet!',
      'opacity': 0.9,
    },
    {
      'icon': Icons.confirmation_number,
      'iconBgColor': AppColors.primaryFixed,
      'iconColor': AppColors.primary,
      'title': 'Tickets Confirmed',
      'timestamp': '1d ago',
      'description':
          'Your order #UE-9021 for "Summer Solstice Gala" is confirmed. See you there!',
      'actionLabel': 'View Receipt',
      'opacity': 0.9,
    },
  ];
}
