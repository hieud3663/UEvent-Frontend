// File: lib/features/event_shared/models/event_question_model.dart

import 'package:frontend/features/event_shared/models/event_registration_model.dart';

class EventQuestionReplyModel {
  final String id;
  final String content;
  final EventUserSummaryModel? user;
  final bool isOrganizerReply;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? timeAgo;

  const EventQuestionReplyModel({
    required this.id,
    required this.content,
    this.user,
    this.isOrganizerReply = false,
    this.createdAt,
    this.updatedAt,
    this.timeAgo,
  });

  String get authorName {
    if (isOrganizerReply) return 'BTC';
    final displayName = user?.displayName.trim() ?? '';
    return displayName.isEmpty ? 'Người tham gia' : displayName;
  }

  factory EventQuestionReplyModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final createdAt = _parseDate(json['created_at']);

    return EventQuestionReplyModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      user: rawUser is Map<String, dynamic>
          ? EventUserSummaryModel.fromJson(rawUser)
          : null,
      isOrganizerReply: json['is_organizer_reply'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _parseDate(json['updated_at']),
      timeAgo: _parseRelativeTime(createdAt),
    );
  }
}

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
  final List<EventQuestionReplyModel> replies;

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
    this.replies = const [],
  });

  bool get isAnswered =>
      (answer != null && answer!.isNotEmpty) || replies.isNotEmpty;

  factory EventQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawAnsweredBy = json['answered_by'];
    final rawReplies = json['replies'];

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
      replies: rawReplies is List
          ? rawReplies
                .whereType<Map<String, dynamic>>()
                .map(EventQuestionReplyModel.fromJson)
                .toList()
          : const [],
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
  final date = value is DateTime ? value : _parseDate(value);
  if (date == null) return null;

  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'just now';
}
