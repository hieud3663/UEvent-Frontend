// File: lib/features/organizer_events/views/manage_event_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/widgets/manage_event_header.dart';
import 'package:frontend/features/organizer_events/widgets/manage_event_location_card.dart';
import 'package:frontend/features/organizer_events/widgets/manage_event_stats_section.dart';
import 'package:frontend/features/organizer_events/widgets/manage_event_tools_section.dart';

class ManageEventView extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onClose;
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onQuestionsTap;

  const ManageEventView({
    super.key,
    required this.event,
    this.onClose,
    this.onEditDetailsTap,
    this.onAttendeeListTap,
    this.onParticipantCheckInTap,
    this.onQuestionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: ManageEventHeader(event: event),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: ManageEventStatsSection(event: event),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: ManageEventToolsSection(
                    onEditDetailsTap: onEditDetailsTap,
                    onAttendeeListTap: onAttendeeListTap,
                    onParticipantCheckInTap: onParticipantCheckInTap,
                    onQuestionsTap: onQuestionsTap,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: ManageEventLocationCard(event: event),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Quản lý sự kiện',
              leadingIcon: Icons.close,
              onLeadingTap: onClose ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
