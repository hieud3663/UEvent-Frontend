class EventUserSummaryModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String avatarUrl;

  const EventUserSummaryModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.avatarUrl = '',
  });

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName;
    if (username.trim().isNotEmpty) return username;
    return email;
  }

  factory EventUserSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventUserSummaryModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? '',
    );
  }
}

class EventTicketSummaryModel {
  final String id;
  final String ticketCode;
  final String status;
  final DateTime? issuedAt;
  final DateTime? expiresAt;

  const EventTicketSummaryModel({
    required this.id,
    required this.ticketCode,
    required this.status,
    this.issuedAt,
    this.expiresAt,
  });

  factory EventTicketSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventTicketSummaryModel(
      id: json['id']?.toString() ?? '',
      ticketCode: json['ticket_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: _parseDate(json['issued_at']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }
}

class EventRegistrationAnswerModel {
  final String fieldId;
  final String value;

  const EventRegistrationAnswerModel({
    required this.fieldId,
    required this.value,
  });

  factory EventRegistrationAnswerModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationAnswerModel(
      fieldId:
          json['fieldId']?.toString() ??
          json['field_id']?.toString() ??
          json['field_key']?.toString() ??
          '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'fieldId': fieldId, 'value': value};
}

class EventRegistrationModel {
  final String id;
  final String status;
  final DateTime? registeredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final List<EventRegistrationAnswerModel> answers;
  final EventUserSummaryModel? user;
  final EventTicketSummaryModel? ticket;

  const EventRegistrationModel({
    required this.id,
    required this.status,
    this.registeredAt,
    this.cancelledAt,
    this.cancelReason,
    this.answers = const [],
    this.user,
    this.ticket,
  });

  bool get canPromoteToCohost => status != 'cancelled' && status != 'rejected';

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final rawUser = json['user'];
    final rawTicket = json['ticket'];

    return EventRegistrationModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      registeredAt: _parseDate(json['registered_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
      cancelReason: json['cancel_reason']?.toString(),
      answers: rawAnswers is List
          ? rawAnswers
                .whereType<Map<String, dynamic>>()
                .map(EventRegistrationAnswerModel.fromJson)
                .toList()
          : const [],
      user: rawUser is Map<String, dynamic>
          ? EventUserSummaryModel.fromJson(rawUser)
          : null,
      ticket: rawTicket is Map<String, dynamic>
          ? EventTicketSummaryModel.fromJson(rawTicket)
          : null,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
