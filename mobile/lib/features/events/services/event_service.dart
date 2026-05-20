import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_model.dart';

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
      final rawCategories = _extractRawList(response.data);
      return rawCategories
          .map(_mapEventCategory)
          .whereType<EventCategoryModel>()
          .toList();
    } on DioException {
      rethrow;
    }
  }

  List<dynamic> _extractRawList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final nested =
          responseData['results'] ??
          responseData['data'] ??
          responseData['items'];
      return nested is List ? nested : const [];
    }

    return responseData is List ? responseData : const [];
  }

  EventCategoryModel? _mapEventCategory(dynamic raw) {
    if (raw is String) {
      return EventCategoryModel(id: raw, name: raw, slug: raw);
    }
    if (raw is Map<String, dynamic>) {
      return EventCategoryModel.fromJson(raw);
    }
    return null;
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
