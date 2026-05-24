// File: lib/features/organizer_events/views/manage_event_hub_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/features/organizer_events/views/manage_event_view.dart';
import 'package:frontend/features/organizer_events/views/invite_guests_view.dart';
import 'package:frontend/features/organizer_events/views/send_notification_view.dart';

class ManageEventHubView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onManageTeamTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onRegistrationQuestionsTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onExportAttendeeListTap;

  const ManageEventHubView({
    super.key,
    required this.onBack,
    this.onEditDetailsTap,
    this.onManageTeamTap,
    this.onArchiveTap,
    this.onAttendeeListTap,
    this.onRegistrationQuestionsTap,
    this.onParticipantCheckInTap,
    this.onExportAttendeeListTap,
  });

  @override
  State<ManageEventHubView> createState() => _ManageEventHubViewState();
}

class _ManageEventHubViewState extends State<ManageEventHubView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              ManageEventView(
                onClose: widget.onBack,
                onEditDetailsTap: widget.onEditDetailsTap,
                onManageTeamTap: widget.onManageTeamTap,
                onArchiveTap: widget.onArchiveTap,
                onAttendeeListTap: widget.onAttendeeListTap,
                onRegistrationQuestionsTap: widget.onRegistrationQuestionsTap,
                onParticipantCheckInTap: widget.onParticipantCheckInTap,
                onExportAttendeeListTap: widget.onExportAttendeeListTap,
              ),
              InviteGuestsView(
                onBack: widget.onBack, // Close this hub view
              ),
              SendNotificationView(
                onBack: widget.onBack, // Close this hub view
              ),
            ],
          ),

          // No need for Positioned wrapper - GlassBottomNavBar handles its own positioning
          GlassBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              NavItemModel(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'MANAGE',
              ),
              NavItemModel(
                icon: Icons.group_add_outlined,
                activeIcon: Icons.group_add,
                label: 'GUESTS',
              ),
              NavItemModel(
                icon: Icons.campaign_outlined,
                activeIcon: Icons.campaign,
                label: 'NOTIFY',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
