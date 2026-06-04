import 'package:flutter/material.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/widgets/bento_stat_card.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_detail_formatters.dart';

class ManageEventStatsSection extends StatelessWidget {
  final EventModel event;

  const ManageEventStatsSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 0.9,
            child: BentoStatCard(
              icon: Icons.how_to_reg,
              title: 'Sức chứa',
              metric: event.guestCount?.toString() ?? '—',
              isHighlightIcon: false,
              centerContent: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AspectRatio(
            aspectRatio: 0.9,
            child: BentoStatCard(
              icon: Icons.analytics,
              title: 'Trạng thái',
              metric: organizerEventStatusLabel(event.status),
              isHighlightIcon: true,
              centerContent: true,
            ),
          ),
        ),
      ],
    );
  }
}
