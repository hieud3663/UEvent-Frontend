import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/features/event_shared/mock/mock_event_data.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_feedback_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/event_shared/models/event_share_link_model.dart';
import 'package:frontend/features/user_events/services/user_event_service.dart';

abstract interface class UserEventRepository {
  Future<List<EventModel>> getEvents({Map<String, dynamic>? queryParams});

  Future<List<EventModel>> getMyRegisteredEvents();

  Future<List<EventModel>> searchEvents({
    int page = 1,
    int pageSize = 10,
    String category = '',
    String status = 'active',
  });

  Future<List<EventCategoryModel>> getEventCategories();
  Future<EventModel> getEventDetail(String eventId);

  Future<EventModel> getEventBySlug(String slug);

  Future<EventShareLinkModel> getEventShareLink(String eventId);

  Future<EventRegistrationModel> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  });

  Future<void> unregisterCurrentUserFromEvent({required String eventId});

  Future<List<EventQuestionModel>> getPublicEventQuestions({
    required String eventId,
  });

  Future<EventQuestionModel> createEventQuestion({
    required String eventId,
    required String questionText,
    required bool isAnonymous,
  });

  Future<EventQuestionReplyModel> createQuestionReply({
    required String questionId,
    required String content,
  });

  Future<List<EventFeedbackModel>> getEventFeedbacks({required String eventId});

  Future<EventFeedbackSummaryModel> getEventFeedbackSummary({
    required String eventId,
  });
}

class UserEventRepositoryImpl implements UserEventRepository {
  final UserEventService _service;

  UserEventRepositoryImpl(this._service);

  @override
  Future<List<EventModel>> getEvents({
    Map<String, dynamic>? queryParams,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.list;
    }

    return _service.getEvents(queryParams: queryParams);
  }

  @override
  Future<List<EventModel>> getMyRegisteredEvents() async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return MockEventData.discoveryEvents
          .take(3)
          .map(
            (event) =>
                event.copyWith(userEventRelation: EventUserRelation.registered),
          )
          .toList();
    }

    return _service.getMyRegisteredEvents();
  }

  @override
  Future<List<EventModel>> searchEvents({
    int page = 1,
    int pageSize = 10,
    String category = '',
    String status = 'active',
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.discoveryEvents;
    }

    return _service.searchEvents(
      page: page,
      pageSize: pageSize,
      category: category,
      status: status,
    );
  }

  @override
  Future<List<EventCategoryModel>> getEventCategories() async {
    if (EnvConfig.useMockData) {
      return MockEventData.discoveryCategories
          .where((category) => category != 'All')
          .map(
            (category) => EventCategoryModel(
              id: category,
              name: category,
              slug: category,
            ),
          )
          .toList();
    }

    return _service.getEventCategories();
  }

  @override
  Future<EventModel> getEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list.firstWhere((event) => event.id == eventId);
    }

    return _service.getEventDetail(eventId);
  }

  @override
  Future<EventModel> getEventBySlug(String slug) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockEventData.list.firstWhere(
        (event) => (event.slug ?? event.id) == slug,
      );
    }

    return _service.getEventBySlug(slug);
  }

  @override
  Future<EventShareLinkModel> getEventShareLink(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final event = MockEventData.list.firstWhere((item) => item.id == eventId);
      final slug = event.slug ?? event.id;
      return EventShareLinkModel(
        eventId: eventId,
        slug: slug,
        shareUrl: 'https://uevent.u-code.dev/events/share/$slug',
        visibility: event.visibility.name,
      );
    }

    return _service.getEventShareLink(eventId);
  }

  @override
  Future<EventRegistrationModel> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return EventRegistrationModel(
        id: 'mock-registration-$eventId',
        eventId: eventId,
        status: 'registered',
        registeredAt: DateTime.now(),
        answers: answers,
        ticket: const EventTicketSummaryModel(
          id: 'mock-ticket-001',
          ticketCode: 'UE-98210',
          status: 'valid',
        ),
      );
    }

    return _service.registerEvent(eventId: eventId, answers: answers);
  }

  @override
  Future<void> unregisterCurrentUserFromEvent({required String eventId}) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    return _service.unregisterCurrentUserFromEvent(eventId: eventId);
  }

  @override
  Future<List<EventQuestionModel>> getPublicEventQuestions({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const [
        EventQuestionModel(
          id: 'mock-question-001',
          question: 'Sự kiện có cấp certificate không?',
          answer: 'Có, certificate sẽ được gửi sau sự kiện.',
          answeredBy: 'Organizer',
          timeAgo: '2h ago',
        ),
        EventQuestionModel(
          id: 'mock-question-002',
          question: 'Có cần mang laptop không?',
          timeAgo: '1h ago',
        ),
      ];
    }

    return _service.getPublicEventQuestions(eventId: eventId);
  }

  @override
  Future<EventQuestionModel> createEventQuestion({
    required String eventId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventQuestionModel(
        id: 'mock-question-${DateTime.now().millisecondsSinceEpoch}',
        question: questionText,
        isAnonymous: isAnonymous,
        timeAgo: 'just now',
      );
    }

    return _service.createEventQuestion(
      eventId: eventId,
      questionText: questionText,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Future<EventQuestionReplyModel> createQuestionReply({
    required String questionId,
    required String content,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return EventQuestionReplyModel(
        id: 'mock-reply-${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        createdAt: DateTime.now(),
        timeAgo: 'just now',
      );
    }

    return _service.createQuestionReply(
      questionId: questionId,
      content: content,
    );
  }

  @override
  Future<List<EventFeedbackModel>> getEventFeedbacks({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        EventFeedbackModel(
          id: 'mock-feedback-001',
          rating: 5,
          content: 'Sự kiện rất hữu ích và tổ chức tốt.',
          isAnonymous: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          user: const EventUserSummaryModel(
            id: 'mock-user-001',
            username: 'attendee',
            fullName: 'Attendee Name',
            email: 'attendee@example.com',
          ),
        ),
      ];
    }

    return _service.getEventFeedbacks(eventId: eventId);
  }

  @override
  Future<EventFeedbackSummaryModel> getEventFeedbackSummary({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return const EventFeedbackSummaryModel(
        eventId: 'mock-event',
        total: 1,
        averageRating: 5,
        ratingCounts: {5: 1},
      );
    }

    return _service.getEventFeedbackSummary(eventId: eventId);
  }
}
