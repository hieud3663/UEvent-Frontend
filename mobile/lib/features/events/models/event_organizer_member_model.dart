import 'package:frontend/features/events/models/event_registration_model.dart';

class EventOrganizerMemberModel {
  final String id;
  final String eventId;
  final EventUserSummaryModel user;
  final String organizerRole;
  final DateTime? joinedAt;

  const EventOrganizerMemberModel({
    required this.id,
    required this.eventId,
    required this.user,
    required this.organizerRole,
    this.joinedAt,
  });

  factory EventOrganizerMemberModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    return EventOrganizerMemberModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      user: rawUser is Map<String, dynamic>
          ? EventUserSummaryModel.fromJson(rawUser)
          : const EventUserSummaryModel(
              id: '',
              username: '',
              fullName: '',
              email: '',
            ),
      organizerRole: json['organizer_role']?.toString() ?? '',
      joinedAt: _parseDate(json['joined_at']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
