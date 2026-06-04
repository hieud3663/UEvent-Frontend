import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_detail_formatters.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_info_row.dart';

class OrganizerEventInfoSection extends StatelessWidget {
  final EventModel event;

  const OrganizerEventInfoSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            event.category?.trim().isNotEmpty == true
                ? event.category!.toUpperCase()
                : 'SỰ KIỆN',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.title,
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        OrganizerEventInfoRow(
          icon: Icons.calendar_month,
          text:
              '${formatOrganizerEventDate(event.startDate)} - ${formatOrganizerEventTimeRange(event)}',
        ),
        const SizedBox(height: 12),
        OrganizerEventInfoRow(
          icon: Icons.location_on,
          text: event.location.isNotEmpty ? event.location : 'Chưa có địa điểm',
        ),
      ],
    );
  }
}
