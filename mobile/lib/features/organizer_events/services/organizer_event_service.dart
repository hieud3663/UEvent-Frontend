import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/event_shared/models/event_cover_upload_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/models/check_in_model.dart';

class OrganizerEventService {
  final ApiClient _apiClient;

  OrganizerEventService(this._apiClient);

  Future<List<EventModel>> getOrganizerEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
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

  Future<List<EventRoomModel>> getEventRooms() async {
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

  Future<EventModel> getOrganizerEventDetail(String eventId) async {
    try {
      final response = await _apiClient.dio.get('/organizer/events/$eventId/');
      return EventModel.fromJson(
        extractObjectData(response.data),
      ).copyWith(isOrganizer: true);
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventRegistrationModel>> getEventRegistrations({
    required String eventId,
    String? status,
    String? search,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/attendees/',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
        },
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

  Future<Map<String, dynamic>> sendEventNotification({
    required String eventId,
    required String title,
    required String message,
    required String audience,
    bool sendPush = true,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/organizer/events/$eventId/notifications/',
        data: {
          'title': title,
          'message': message,
          'audience': audience,
          'send_push': sendPush,
        },
      );
      return extractObjectData(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventOrganizerMemberModel>> getEventOrganizers({
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/organizer/events/$eventId/organizers/',
      );
      final dataList = extractListData(response.data);
      return dataList.map(EventOrganizerMemberModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventOrganizerMemberModel> addEventOrganizerByEmail({
    required String eventId,
    required String email,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/organizer/events/$eventId/organizers/',
        data: {'email': email},
      );
      return EventOrganizerMemberModel.fromJson(
        extractObjectData(response.data),
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> removeEventOrganizerByEmail({
    required String eventId,
    required String email,
  }) async {
    try {
      await _apiClient.dio.delete(
        '/organizer/events/$eventId/organizers/',
        data: {'email': email},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<CheckInResultModel> checkInRegistration({
    required String eventId,
    String? qrPayload,
    String? qrSignature,
    String? email,
    String? note,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/events/$eventId/check-in/scan/',
        data: {
          if (qrPayload != null && qrPayload.isNotEmpty)
            'qr_payload': qrPayload,
          if (qrSignature != null && qrSignature.isNotEmpty)
            'qr_signature': qrSignature,
          if (email != null && email.isNotEmpty) 'email': email,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return CheckInResultModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<List<CheckInLogModel>> getCheckInLogs({
    required String eventId,
    String? result,
    String? search,
    String? userId,
    String? ticketId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/check-ins/',
        queryParameters: {
          if (result != null && result.isNotEmpty) 'result': result,
          if (search != null && search.isNotEmpty) 'search': search,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
          if (ticketId != null && ticketId.isNotEmpty) 'ticket_id': ticketId,
        },
      );
      final dataList = extractListData(response.data);
      return dataList.map(CheckInLogModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<List<EventQuestionModel>> getOrganizerEventQuestions({
    required String eventId,
  }) async {
    try {
      final response = await _apiClient.dio.get('/events/$eventId/questions/');
      final dataList = extractListData(response.data);
      return dataList.map(EventQuestionModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<bool> getAiAssistantEnabled({required String eventId}) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/ai-assistant/',
      );
      return _parseAiAssistantEnabled(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<bool> updateAiAssistantEnabled({
    required String eventId,
    required bool isEnabled,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/events/$eventId/ai-assistant/',
        data: {'is_enabled': isEnabled},
      );
      if (response.data == null || response.data == '') return isEnabled;
      return _parseAiAssistantEnabled(response.data);
    } on DioException {
      rethrow;
    }
  }

  bool _parseAiAssistantEnabled(dynamic responseData) {
    final data = extractObjectData(responseData);
    final isEnabled = data['is_enabled'];
    if (isEnabled is bool) return isEnabled;
    throw const FormatException('Expected is_enabled to be a boolean');
  }

  Future<EventQuestionModel> answerEventQuestion({
    required String questionId,
    required String answerText,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/questions/$questionId/answer/',
        data: {'answer_text': answerText},
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
}
