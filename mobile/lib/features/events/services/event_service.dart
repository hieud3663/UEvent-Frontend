import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/models/event_cover_upload_model.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_model.dart';
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

  Future<EventCoverUploadModel> getEventCoverPresignedUrl({
    required String fileName,
    required String contentType,
  }) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return EventCoverUploadModel(
        objectKey: 'events/mock/covers/$fileName',
        presignedUrl: 'https://example.com/mock-presigned-url',
        publicUrl: 'https://example.com/events/mock/covers/$fileName',
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

  Future<EventModel> getEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list.firstWhere((e) => e.id == eventId);
    }

    try {
      final response = await _apiClient.dio.get('/events/$eventId');
      return EventModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }
}
