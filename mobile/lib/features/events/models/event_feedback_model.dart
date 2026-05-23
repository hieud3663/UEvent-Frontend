import 'package:frontend/features/events/models/event_registration_model.dart';

class EventFeedbackModel {
  final String id;
  final EventUserSummaryModel? user;
  final int rating;
  final String content;
  final bool isAnonymous;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventFeedbackModel({
    required this.id,
    this.user,
    required this.rating,
    required this.content,
    required this.isAnonymous,
    this.createdAt,
    this.updatedAt,
  });

  String get authorName {
    if (isAnonymous) return 'Anonymous';
    return user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'Attendee';
  }

  factory EventFeedbackModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];

    return EventFeedbackModel(
      id: json['id']?.toString() ?? '',
      user: rawUser is Map<String, dynamic>
          ? EventUserSummaryModel.fromJson(rawUser)
          : null,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      content: json['content']?.toString() ?? json['comment']?.toString() ?? '',
      isAnonymous:
          json['is_anonymous'] as bool? ??
          json['isAnonymous'] as bool? ??
          false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

class EventFeedbackSummaryModel {
  final String eventId;
  final int total;
  final double averageRating;
  final Map<int, int> ratingCounts;

  const EventFeedbackSummaryModel({
    required this.eventId,
    required this.total,
    required this.averageRating,
    required this.ratingCounts,
  });

  factory EventFeedbackSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['rating_counts'];

    return EventFeedbackSummaryModel(
      eventId: json['event_id']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      ratingCounts: rawCounts is Map
          ? rawCounts.map(
              (key, value) => MapEntry(
                int.tryParse(key.toString()) ?? 0,
                (value as num?)?.toInt() ?? 0,
              ),
            )
          : const {},
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
