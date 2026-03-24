// File: lib/features/events/models/event_question_model.dart

class EventQuestionModel {
  final String id;
  final String question;
  final String? answer;
  final String? answeredBy;
  final String? timeAgo;
  final bool isAnonymous;

  const EventQuestionModel({
    required this.id,
    required this.question,
    this.answer,
    this.answeredBy,
    this.timeAgo,
    this.isAnonymous = false,
  });

  bool get isAnswered => answer != null && answer!.isNotEmpty;
}
