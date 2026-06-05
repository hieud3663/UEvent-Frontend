import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_feedback_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/event_shared/models/event_share_link_model.dart';

class UserEventService {
  final ApiClient _apiClient;

  UserEventService(this._apiClient);

  Future<List<EventModel>> getEvents({
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/search/',
        queryParameters: queryParams,
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventModel>> getMyRegisteredEvents() async {
    try {
      final response = await _apiClient.dio.get('/events/registrations/me/');
      final dataList = extractListData(response.data);
      return dataList.map(_eventFromRegistrationListItem).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventModel>> searchEvents({
    int page = 1,
    int pageSize = 10,
    String category = '',
    String search = '',
    String status = 'active',
  }) async {
    final normalizedSearch = search.trim();
    try {
      final response = await _apiClient.dio.get(
        '/events/search/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (category.trim().isNotEmpty) 'category': category.trim(),
          if (normalizedSearch.isNotEmpty) 'search': normalizedSearch,
          'status': status,
        },
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventCategoryModel>> getEventCategories() async {
    try {
      final response = await _apiClient.dio.get('/event-categories/');
      final dataList = extractListData(response.data);
      return dataList.map(EventCategoryModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> getEventDetail(String eventId) async {
    try {
      final response = await _apiClient.dio.get('/events/$eventId/');
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> getEventBySlug(String slug) async {
    try {
      final encodedSlug = Uri.encodeComponent(slug);
      final response = await _apiClient.dio.get('/events/slug/$encodedSlug/');
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventShareLinkModel> getEventShareLink(String eventId) async {
    try {
      final response = await _apiClient.dio.get('/events/$eventId/share-link/');
      return EventShareLinkModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventRegistrationModel> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/events/$eventId/registrations/',
        data: {'answers': answers.map((answer) => answer.toJson()).toList()},
      );
      return EventRegistrationModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> unregisterCurrentUserFromEvent({required String eventId}) async {
    try {
      await _apiClient.dio.delete('/events/$eventId/registrations/me/');
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventQuestionModel>> getPublicEventQuestions({
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/questions/public/',
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventQuestionModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventQuestionModel> createEventQuestion({
    required String eventId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/events/$eventId/questions/',
        data: {'question_text': questionText, 'is_anonymous': isAnonymous},
      );
      return EventQuestionModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventQuestionReplyModel> createQuestionReply({
    required String questionId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/questions/$questionId/replies/',
        data: {'content': content},
      );
      return EventQuestionReplyModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventFeedbackModel>> getEventFeedbacks({
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.dio.get('/events/$eventId/feedbacks/');
      final dataList = extractListData(response.data);
      return dataList.map(EventFeedbackModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventFeedbackSummaryModel> getEventFeedbackSummary({
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/feedbacks/summary/',
      );
      return EventFeedbackSummaryModel.fromJson(
        extractObjectData(response.data),
      );
    } on DioException {
      rethrow;
    }
  }
}

EventModel _eventFromRegistrationListItem(Map<String, dynamic> json) {
  final nestedEvent = json['event'];
  if (nestedEvent is Map<String, dynamic>) {
    return EventModel.fromJson(
      nestedEvent,
    ).copyWith(userEventRelation: EventUserRelation.registered);
  }

  return EventModel.fromJson(
    json,
  ).copyWith(userEventRelation: EventUserRelation.registered);
}
