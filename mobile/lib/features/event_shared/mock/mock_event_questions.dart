// File: lib/features/event_shared/mock/mock_event_questions.dart

import '../models/event_question_model.dart';

class MockEventQuestions {
  static const List<EventQuestionModel> questions = [
    EventQuestionModel(
      id: 'q1',
      question: 'Is there a student discount available?',
      answer:
          'Yes! Students with a valid .edu email can use code STU2024 for 50% off.',
      answeredBy: 'Organizers',
      timeAgo: '2h ago',
    ),
    EventQuestionModel(id: 'q2', question: 'Will the sessions be recorded?'),
    EventQuestionModel(
      id: 'q3',
      question: 'Is parking available near the venue?',
      answer:
          'Yes, there are multiple parking garages within a 5-minute walk. We recommend the Howard Street Garage.',
      answeredBy: 'Organizers',
      timeAgo: '5h ago',
    ),
  ];
}
