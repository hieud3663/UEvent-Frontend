import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/ticketing/mock/mock_ticket_data.dart';
import 'package:frontend/features/ticketing/models/ticket_dto.dart';

class TicketingService {
  final ApiClient _apiClient;

  TicketingService(this._apiClient);

  Future<UserRegistrationDTO> registerForEvent(String eventId, Map<String, dynamic> answers) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockTicketData.myRegistration;
    }

    try {
      final response = await _apiClient.dio.post('/events/\$eventId/register', data: answers);
      return UserRegistrationDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to register: \${e.message}');
    }
  }

  Future<TicketDTO> getTicketForEvent(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockTicketData.myValidTicket;
    }

    try {
      final response = await _apiClient.dio.get('/events/\$eventId/ticket');
      return TicketDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch ticket: \${e.message}');
    }
  }

  /// Request a new rotated QR token
  Future<TicketDTO> rotateQrToken(String ticketCode) async {
    if (EnvConfig.useMockData) {
      // Simulate new token generated
      return MockTicketData.myValidTicket.copyWith(
        validFrom: DateTime.now(),
        validTo: DateTime.now().add(const Duration(seconds: 15)),
      );
    }

    try {
      final response = await _apiClient.dio.post('/tickets/\$ticketCode/rotate_qr');
      return TicketDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to rotate QR: \${e.message}');
    }
  }
}
