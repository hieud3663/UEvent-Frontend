import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/models/event_model.dart';

class EventService {
  final ApiClient _apiClient;

  EventService(this._apiClient);

  Future<List<EventModel>> getEvents({Map<String, dynamic>? queryParams}) async {
    if (true) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      return MockEventData.list;
    }

    try {
      final response = await _apiClient.dio.get('/events', queryParameters: queryParams);
      final dataList = extractListData(response.data);
      return dataList.map(EventModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<EventModel> getEventDetail(String eventId) async {
    if (true) {
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
