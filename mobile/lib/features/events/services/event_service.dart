import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/events/mock/mock_event_data.dart';
import 'package:frontend/features/events/models/event_dto.dart';

class EventService {
  final ApiClient _apiClient;

  EventService(this._apiClient);

  Future<List<EventDTO>> getEvents({Map<String, dynamic>? queryParams}) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
      return MockEventData.list;
    }

    try {
      final response = await _apiClient.dio.get('/events', queryParameters: queryParams);
      final List<dynamic> dataList = response.data['results'] ?? response.data;
      return dataList.map((json) => EventDTO.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch events: \${e.message}');
    }
  }

  Future<EventDTO> getEventDetail(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return MockEventData.list.firstWhere((e) => e.id == eventId);
    }

    try {
      final response = await _apiClient.dio.get('/events/\$eventId');
      return EventDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch event details: \${e.message}');
    }
  }
}
