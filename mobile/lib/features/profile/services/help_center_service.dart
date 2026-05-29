import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/response_parsing.dart';
import 'package:frontend/features/profile/models/help_center_models.dart';

class HelpCenterService {
  final ApiClient _apiClient;

  const HelpCenterService(this._apiClient);

  Future<List<HelpCenterCategoryModel>> getHelpCenter({
    required String locale,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/support/help-center/',
        queryParameters: {'locale': locale},
      );
      return extractListData(
        response.data,
      ).map(HelpCenterCategoryModel.fromJson).toList(growable: false);
    } on DioException {
      rethrow;
    }
  }

  Future<HelpCenterArticleModel> getArticle({
    required String slug,
    required String locale,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/support/help-center/articles/$slug/',
        queryParameters: {'locale': locale},
      );
      return HelpCenterArticleModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<SupportTicketModel> createSupportTicket({
    required String subject,
    required String description,
    String category = 'technical',
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/support/tickets/',
        data: {
          'subject': subject,
          'description': description,
          'category': category,
        },
      );
      return SupportTicketModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<List<SupportTicketModel>> getSupportTickets() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/support/tickets/',
      );
      return extractListData(
        response.data,
      ).map(SupportTicketModel.fromJson).toList(growable: false);
    } on DioException {
      rethrow;
    }
  }

  Future<SupportTicketModel> getSupportTicket(String ticketId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/support/tickets/$ticketId/',
      );
      return SupportTicketModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<SupportTicketModel> addSupportTicketMessage({
    required String ticketId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/support/tickets/$ticketId/messages/',
        data: {'content': content},
      );
      return SupportTicketModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }

  Future<LegalDocumentModel> getLegalDocument({
    required String documentType,
    required String locale,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/support/legal-documents/$documentType/',
        queryParameters: {'locale': locale},
      );
      return LegalDocumentModel.fromJson(extractObjectData(response.data));
    } on DioException {
      rethrow;
    }
  }
}
