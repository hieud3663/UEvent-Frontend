import 'package:frontend/features/event_shared/models/event_registration_model.dart';

class CheckInResultModel {
  final String result;
  final EventRegistrationModel? registration;
  final EventTicketSummaryModel? ticket;

  const CheckInResultModel({
    required this.result,
    this.registration,
    this.ticket,
  });

  bool get isSuccess => result == 'success';

  factory CheckInResultModel.fromJson(Map<String, dynamic> json) {
    final rawRegistration = json['registration'];
    final rawTicket = json['ticket'];

    return CheckInResultModel(
      result: json['result']?.toString() ?? '',
      registration: rawRegistration is Map<String, dynamic>
          ? EventRegistrationModel.fromJson(rawRegistration)
          : null,
      ticket: rawTicket is Map<String, dynamic>
          ? EventTicketSummaryModel.fromJson(rawTicket)
          : null,
    );
  }
}

class CheckInLogModel {
  final String id;
  final String result;
  final String note;
  final DateTime? createdAt;
  final EventRegistrationModel? registration;

  const CheckInLogModel({
    required this.id,
    required this.result,
    required this.note,
    this.createdAt,
    this.registration,
  });

  factory CheckInLogModel.fromJson(Map<String, dynamic> json) {
    final rawRegistration = json['registration'];

    return CheckInLogModel(
      id: json['id']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      registration: rawRegistration is Map<String, dynamic>
          ? EventRegistrationModel.fromJson(rawRegistration)
          : null,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
