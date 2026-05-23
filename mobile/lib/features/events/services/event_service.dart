import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/models/event_cover_upload_model.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_feedback_model.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_organizer_member_model.dart';
import 'package:frontend/features/events/models/event_question_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/models/event_room_model.dart';

class EventService {
  final ApiClient _apiClient;

  EventService(this._apiClient);

  Future<List<EventModel>> getEvents({
    Map<String, dynamic>? queryParams,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network latency
      return MockEventData.list;
    }

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

    try {
      final response = await _apiClient.dio.get(
        '/events/search/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'category': category,
          'status': status,
        },
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventModel>> getOrganizerEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.list
          .where((event) => event.isOrganizer)
          .take(pageSize)
          .toList();
    }

    try {
      final response = await _apiClient.dio.get(
        '/organizer/events/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

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

    try {
      final response = await _apiClient.dio.get('/event-categories/');
      final dataList = extractListData(response.data);
      return dataList.map(EventCategoryModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventRoomModel>> getEventRooms() async {
    if (EnvConfig.useMockData) {
      return const [
        EventRoomModel(
          id: 'mock-room-a1',
          name: 'Auditorium',
          code: 'A1',
          capacity: 120,
        ),
      ];
    }

    try {
      final response = await _apiClient.dio.get('/locations/rooms/');
      final dataList = extractListData(response.data);
      if (dataList.isNotEmpty) {
        return dataList.map(EventRoomModel.fromJson).toList();
      }

      final dataObject = _extractRoomObject(response.data);
      return dataObject == null
          ? const []
          : [EventRoomModel.fromJson(dataObject)];
    } on DioException {
      rethrow;
    }
  }

  Map<String, dynamic>? _extractRoomObject(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return null;
    }

    final nested = responseData['data'] ?? responseData['result'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }

    if (responseData.containsKey('id') || responseData.containsKey('name')) {
      return responseData;
    }

    return null;
  }

  Future<EventModel> createOrganizerEvent(Map<String, dynamic> payload) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockEventData.mockEventLaunchParty.copyWith(
        title: payload['title']?.toString() ?? 'Draft event',
        isOrganizer: true,
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/organizer/events/',
        data: payload,
      );
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> updateOrganizerEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return MockEventData.mockEventLaunchParty.copyWith(
        id: eventId,
        title:
            payload['title']?.toString() ??
            MockEventData.mockEventLaunchParty.title,
        description:
            payload['description']?.toString() ??
            MockEventData.mockEventLaunchParty.description,
        category:
            payload['category']?.toString() ??
            MockEventData.mockEventLaunchParty.category,
        location:
            payload['location_snapshot']?.toString() ??
            MockEventData.mockEventLaunchParty.location,
        guestCount:
            (payload['max_capacity'] as num?)?.toInt() ??
            MockEventData.mockEventLaunchParty.guestCount,
        startDate: payload['start_at'] is String
            ? DateTime.parse(payload['start_at'] as String)
            : MockEventData.mockEventLaunchParty.startDate,
        endDate: payload['end_at'] is String
            ? DateTime.parse(payload['end_at'] as String)
            : MockEventData.mockEventLaunchParty.endDate,
        visibility: payload['visibility'] == 'private'
            ? EventVisibility.private
            : EventVisibility.public,
        isOrganizer: true,
      );
    }

    try {
      final response = await _apiClient.dio.patch(
        '/organizer/events/$eventId/',
        data: payload,
      );
      return EventModel.fromJson(
        extractObjectData(response.data),
      ).copyWith(isOrganizer: true);
    } on DioException {
      rethrow;
    }
  }

  Future<EventCoverUploadModel> getEventCoverPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventCoverUploadModel(
        objectKey: 'events/mock/covers/$fileName',
        presignedUrl: 'https://example.com/mock-presigned-url',
        method: 'PUT',
        expiresIn: 3600,
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/organizer/events/presigned-url/',
        data: {'file_name': fileName, 'content_type': contentType},
      );
      return EventCoverUploadModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<void> uploadEventCoverImage({
    required File imageFile,
    required String presignedUrl,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    final uploadClient = Dio();
    final bytes = await imageFile.readAsBytes();

    try {
      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: presignedUrl,
        bytes: bytes,
        contentType: contentType,
      );
    } on DioException catch (error) {
      final redirectUrl = _s3TemporaryRedirectUrl(error, presignedUrl);
      if (redirectUrl == null) rethrow;

      await _putPresignedObject(
        uploadClient: uploadClient,
        presignedUrl: redirectUrl,
        bytes: bytes,
        contentType: contentType,
      );
    }
  }

  Future<void> _putPresignedObject({
    required Dio uploadClient,
    required String presignedUrl,
    required List<int> bytes,
    required String contentType,
  }) {
    return uploadClient.put<void>(
      presignedUrl,
      data: bytes,
      options: Options(
        contentType: contentType,
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
        responseType: ResponseType.plain,
      ),
    );
  }

  String? _s3TemporaryRedirectUrl(DioException error, String originalUrl) {
    if (error.response?.statusCode != 307) return null;

    final responseBody = error.response?.data?.toString();
    if (responseBody == null) return null;

    final endpointMatch = RegExp(
      r'<Endpoint>([^<]+)</Endpoint>',
    ).firstMatch(responseBody);
    final endpoint = endpointMatch?.group(1);
    if (endpoint == null || endpoint.isEmpty) return null;

    final originalUri = Uri.parse(originalUrl);
    return originalUri.replace(host: endpoint).toString();
  }

  Future<EventModel> updateOrganizerEventCover({
    required String eventId,
    required String coverImageKey,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockEventData.mockEventLaunchParty.copyWith(
        id: eventId,
        imageUrl: 'https://example.com/$coverImageKey',
        isOrganizer: true,
      );
    }

    try {
      final response = await _apiClient.dio.patch(
        '/organizer/events/$eventId/',
        data: {'cover_image_key': coverImageKey},
      );
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> getEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list.firstWhere((e) => e.id == eventId);
    }

    try {
      final response = await _apiClient.dio.get('/events/$eventId/');
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> getOrganizerEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list
          .firstWhere((e) => e.id == eventId)
          .copyWith(isOrganizer: true);
    }

    try {
      final response = await _apiClient.dio.get('/organizer/events/$eventId/');
      return EventModel.fromJson(
        extractObjectData(response.data),
      ).copyWith(isOrganizer: true);
    } on DioException {
      rethrow;
    }
  }

  Future<EventRegistrationModel> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return EventRegistrationModel(
        id: 'mock-registration-$eventId',
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

  Future<List<EventRegistrationModel>> getEventRegistrations({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 700));
      return [
        EventRegistrationModel(
          id: 'mock-registration-001',
          status: 'registered',
          registeredAt: DateTime.now().subtract(const Duration(hours: 2)),
          user: const EventUserSummaryModel(
            id: 'mock-user-001',
            username: 'attendee',
            fullName: 'Attendee Name',
            email: 'attendee@example.com',
          ),
          ticket: const EventTicketSummaryModel(
            id: 'mock-ticket-001',
            ticketCode: 'UE-98210',
            status: 'valid',
          ),
        ),
        EventRegistrationModel(
          id: 'mock-registration-002',
          status: 'waitlisted',
          registeredAt: DateTime.now().subtract(const Duration(hours: 1)),
          user: const EventUserSummaryModel(
            id: 'mock-user-002',
            username: 'waitlist',
            fullName: 'Waitlist User',
            email: 'waitlist@example.com',
          ),
        ),
      ];
    }

    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/registrations/',
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventRegistrationModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventOrganizerMemberModel> promoteRegistrationToCohost({
    required String eventId,
    required String registrationId,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return const EventOrganizerMemberModel(
        id: 'mock-cohost-001',
        eventId: 'mock-event',
        user: EventUserSummaryModel(
          id: 'mock-user-001',
          username: 'attendee',
          fullName: 'Attendee Name',
          email: 'attendee@example.com',
        ),
        organizerRole: 'co_host',
      );
    }

    try {
      final response = await _apiClient.dio.post(
        '/organizer/events/$eventId/registrations/$registrationId/cohost/',
      );
      return EventOrganizerMemberModel.fromJson(
        extractObjectData(response.data),
      );
    } on DioException {
      rethrow;
    }
  }

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

  Future<List<EventQuestionModel>> getOrganizerEventQuestions({
    required String eventId,
  }) async {
    if (EnvConfig.useMockData) {
      return getPublicEventQuestions(eventId: eventId);
    }

    try {
      final response = await _apiClient.dio.get('/events/$eventId/questions/');
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
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventQuestionModel(
        id: 'mock-question-${DateTime.now().millisecondsSinceEpoch}',
        question: questionText,
        isAnonymous: isAnonymous,
        timeAgo: 'just now',
      );
    }

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
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return const EventFeedbackSummaryModel(
        eventId: 'mock-event',
        total: 1,
        averageRating: 5,
        ratingCounts: {5: 1},
      );
    }

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
