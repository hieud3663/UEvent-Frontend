// File: lib/features/events/models/event_question_model.dart

class EventQuestionModel {
  final String id;
  final String question;
  final String? answer;
  final String? answeredBy;
  final String? timeAgo;
  final bool isAnonymous;
  final bool isPinned;
  final String moderationStatus;
  final DateTime? askedAt;
  final DateTime? answeredAt;

  const EventQuestionModel({
    required this.id,
    required this.question,
    this.answer,
    this.answeredBy,
    this.timeAgo,
    this.isAnonymous = false,
    this.isPinned = false,
    this.moderationStatus = 'visible',
    this.askedAt,
    this.answeredAt,
  });

  bool get isAnswered => answer != null && answer!.isNotEmpty;

  factory EventQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawAnsweredBy = json['answered_by'];

    return EventQuestionModel(
      id: json['id']?.toString() ?? '',
      question:
          json['question_text']?.toString() ??
          json['question']?.toString() ??
          '',
      answer: json['answer_text']?.toString() ?? json['answer']?.toString(),
      answeredBy: _parseUserName(rawAnsweredBy),
      timeAgo: _parseRelativeTime(json['asked_at'] ?? json['created_at']),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      moderationStatus: json['moderation_status']?.toString() ?? 'visible',
      askedAt: _parseDate(json['asked_at']),
      answeredAt: _parseDate(json['answered_at']),
    );
  }
}

String? _parseUserName(dynamic value) {
  if (value is! Map<String, dynamic>) return null;
  return value['full_name']?.toString() ??
      value['username']?.toString() ??
      value['email']?.toString();
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _parseRelativeTime(dynamic value) {
  final date = _parseDate(value);
  if (date == null) return null;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}
