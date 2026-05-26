import 'package:dio/dio.dart';
import 'package:frontend/core/config/env_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/ticketing/mock/mock_ticket_data.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';

class TicketingService {
  final ApiClient _apiClient;

  TicketingService(this._apiClient);

  Future<List<TicketModel>> getMyTickets({String? status}) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (status == 'past') {
        return MockTicketData.pastTickets;
      }
      return MockTicketData.upcomingTickets;
    }

    try {
      final response = await _apiClient.dio.get(
        '/tickets/me/',
        queryParameters: status == null ? null : {'status': status},
      );

      final data = extractListData(response.data);
      return data.map(TicketModel.fromJson).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<UserRegistrationModel> registerForEvent(
    String eventId,
    Map<String, dynamic> answers,
  ) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(seconds: 1));
      return MockTicketData.myRegistration;
    }

    try {
      final response = await _apiClient.dio.post(
        '/events/$eventId/register',
        data: answers,
      );
      return UserRegistrationModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<RegistrationTicketModel> getEventTicket(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return RegistrationTicketModel(
        registrationId:
            MockTicketData.myValidTicket.registrationId ?? 'mock-reg-001',
        eventId: eventId,
        ticketCode: MockTicketData.myValidTicket.ticketCode,
        status: 'valid',
        issuedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );
    }

    try {
      final response = await _apiClient.dio.get('/events/$eventId/ticket/');
      return RegistrationTicketModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<TicketQrTokenModel> getEventTicketToken(String eventId) async {
    if (EnvConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final now = DateTime.now();
      return TicketQrTokenModel(
        registrationId:
            MockTicketData.myValidTicket.registrationId ?? 'mock-reg-001',
        eventId: eventId,
        ticketCode: MockTicketData.myValidTicket.ticketCode,
        qrPayload: 'TICKET:mock-${now.millisecondsSinceEpoch}',
        qrSignature: 'mock-signature-${now.millisecondsSinceEpoch}',
        validFrom: now,
        validTo: now.add(const Duration(seconds: 15)),
      );
    }

    try {
      final response = await _apiClient.dio.get(
        '/events/$eventId/ticket/token/',
      );
      return TicketQrTokenModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  /// Request a new rotated QR token
  Future<TicketModel> rotateQrToken(String ticketCode) async {
    if (EnvConfig.useMockData) {
      // Simulate new token generated
      return MockTicketData.myValidTicket;
    }

    try {
      final response = await _apiClient.dio.post(
        '/tickets/$ticketCode/rotate_qr',
      );
      return TicketModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }
}
