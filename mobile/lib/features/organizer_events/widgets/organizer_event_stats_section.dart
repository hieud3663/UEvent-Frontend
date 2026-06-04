import 'package:flutter/material.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_stat_card.dart';

class OrganizerEventStatsSection extends StatelessWidget {
  final EventModel event;

  const OrganizerEventStatsSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OrganizerEventStatCard(
            label: 'SỨC CHỨA',
            value: event.guestCount == null
                ? 'Chưa giới hạn'
                : '${event.guestCount}',
            icon: Icons.groups_2_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OrganizerEventStatCard(
            label: 'ĐỘI NGŨ BTC',
            value: '${event.organizers.length}',
            icon: Icons.badge_outlined,
          ),
        ),
      ],
    );
  }
}
