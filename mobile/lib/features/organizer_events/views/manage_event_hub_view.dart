// File: lib/features/organizer_events/views/manage_event_hub_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/views/manage_event_view.dart';

class ManageEventHubView extends StatelessWidget {
  final EventModel event;
  final VoidCallback onBack;
  final VoidCallback? onEditDetailsTap;
  final VoidCallback? onAttendeeListTap;
  final VoidCallback? onParticipantCheckInTap;
  final VoidCallback? onQuestionsFeedbackTap;

  const ManageEventHubView({
    super.key,
    required this.event,
    required this.onBack,
    this.onEditDetailsTap,
    this.onAttendeeListTap,
    this.onParticipantCheckInTap,
    this.onQuestionsFeedbackTap,
  });

  @override
  Widget build(BuildContext context) {
    return ManageEventView(
      event: event,
      onClose: onBack,
      onEditDetailsTap: onEditDetailsTap,
      onAttendeeListTap: onAttendeeListTap,
      onParticipantCheckInTap: onParticipantCheckInTap,
      onQuestionsFeedbackTap: onQuestionsFeedbackTap,
    );
  }
}
