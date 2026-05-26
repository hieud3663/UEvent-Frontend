// File: lib/features/ticketing/models/ticket_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'ticket_model.g.dart';

/// Data class representing a registered ticket for an event.
@JsonSerializable(fieldRename: FieldRename.snake)
class TicketModel {
  final String id;
  final String? registrationId;
  final String eventId;
  final String eventName;
  final String eventImageUrl;
  final String? qrPayload;
  final String? qrSignature;
  final DateTime? validFrom;
  final DateTime? validTo;
  final DateTime? usedAt;
  final String date;
  final String timeRange;
  final String location;
  final String ticketCode;
  final String section;
  final String? row;
  final String? seat;
  final String orderId;
  final String? guestType;
  @JsonKey(unknownEnumValue: TicketStatus.upcoming)
  final TicketStatus status;

  const TicketModel({
    required this.id,
    this.registrationId,
    required this.eventId,
    required this.eventName,
    required this.eventImageUrl,
    this.qrPayload,
    this.qrSignature,
    this.validFrom,
    this.validTo,
    this.usedAt,
    required this.date,
    required this.timeRange,
    required this.location,
    required this.ticketCode,
    required this.section,
    this.row,
    this.seat,
    required this.orderId,
    this.guestType,
    this.status = TicketStatus.upcoming,
  });

  TicketModel copyWith({
    String? id,
    String? registrationId,
    String? eventId,
    String? eventName,
    String? eventImageUrl,
    String? qrPayload,
    String? qrSignature,
    DateTime? validFrom,
    DateTime? validTo,
    DateTime? usedAt,
    String? date,
    String? timeRange,
    String? location,
    String? ticketCode,
    String? section,
    String? row,
    String? seat,
    String? orderId,
    String? guestType,
    TicketStatus? status,
  }) {
    return TicketModel(
      id: id ?? this.id,
      registrationId: registrationId ?? this.registrationId,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      qrPayload: qrPayload ?? this.qrPayload,
      qrSignature: qrSignature ?? this.qrSignature,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      usedAt: usedAt ?? this.usedAt,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      location: location ?? this.location,
      ticketCode: ticketCode ?? this.ticketCode,
      section: section ?? this.section,
      row: row ?? this.row,
      seat: seat ?? this.seat,
      orderId: orderId ?? this.orderId,
      guestType: guestType ?? this.guestType,
      status: status ?? this.status,
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  bool get isCheckedIn =>
      status == TicketStatus.checkedIn ||
      status == TicketStatus.used ||
      usedAt != null;
}

enum TicketStatus {
  upcoming,
  past,
  cancelled,
  @JsonValue('checked_in')
  checkedIn,
  used,
}

class RegistrationTicketModel {
  final String registrationId;
  final String eventId;
  final String ticketCode;
  final String status;
  final DateTime? issuedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  const RegistrationTicketModel({
    required this.registrationId,
    required this.eventId,
    required this.ticketCode,
    required this.status,
    this.issuedAt,
    this.usedAt,
    this.expiresAt,
  });

  factory RegistrationTicketModel.fromJson(Map<String, dynamic> json) {
    final rawEvent = json['event'];

    return RegistrationTicketModel(
      registrationId:
          json['registration_id']?.toString() ??
          json['registrationId']?.toString() ??
          json['id']?.toString() ??
          '',
      eventId:
          json['event_id']?.toString() ??
          json['eventId']?.toString() ??
          (rawEvent is Map<String, dynamic>
              ? rawEvent['id']?.toString()
              : null) ??
          '',
      ticketCode: json['ticket_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: _parseDate(json['issued_at']),
      usedAt: _parseDate(json['used_at']),
      expiresAt: _parseDate(json['expires_at']),
    );
  }

  TicketModel toTicketModel({
    required String fallbackEventId,
    required String eventName,
    required String eventImageUrl,
    required String date,
    required String timeRange,
    required String location,
  }) {
    return TicketModel(
      id: registrationId,
      registrationId: registrationId,
      eventId: eventId.isNotEmpty ? eventId : fallbackEventId,
      eventName: eventName,
      eventImageUrl: eventImageUrl,
      date: date,
      timeRange: timeRange,
      location: location,
      ticketCode: ticketCode,
      section: 'General',
      orderId: registrationId,
      usedAt: usedAt,
      status: _ticketStatusFromApi(status, usedAt: usedAt),
    );
  }
}

TicketStatus _ticketStatusFromApi(String status, {DateTime? usedAt}) {
  if (usedAt != null) return TicketStatus.checkedIn;

  return switch (status.trim().toLowerCase()) {
    'checked_in' || 'checkedin' || 'used' => TicketStatus.checkedIn,
    'cancelled' || 'canceled' => TicketStatus.cancelled,
    'expired' || 'past' => TicketStatus.past,
    _ => TicketStatus.upcoming,
  };
}

class TicketQrTokenModel {
  final String registrationId;
  final String eventId;
  final String ticketCode;
  final String qrPayload;
  final String qrSignature;
  final DateTime? validFrom;
  final DateTime? validTo;

  const TicketQrTokenModel({
    required this.registrationId,
    required this.eventId,
    required this.ticketCode,
    required this.qrPayload,
    required this.qrSignature,
    this.validFrom,
    this.validTo,
  });

  bool get hasSignedPayload =>
      qrPayload.trim().isNotEmpty && qrSignature.trim().isNotEmpty;

  factory TicketQrTokenModel.fromJson(Map<String, dynamic> json) {
    return TicketQrTokenModel(
      registrationId:
          json['registration_id']?.toString() ??
          json['registrationId']?.toString() ??
          '',
      eventId:
          json['event_id']?.toString() ?? json['eventId']?.toString() ?? '',
      ticketCode: json['ticket_code']?.toString() ?? '',
      qrPayload: json['qr_payload']?.toString() ?? '',
      qrSignature: json['qr_signature']?.toString() ?? '',
      validFrom: _parseDate(json['valid_from']),
      validTo: _parseDate(json['valid_to']),
    );
  }

  Map<String, dynamic> toQrContentJson() => {
    'qr_payload': qrPayload,
    'qr_signature': qrSignature,
  };
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserRegistrationModel {
  final String id;
  final String eventId;
  final String status;
  final bool answersLocked;
  final DateTime registeredAt;

  const UserRegistrationModel({
    required this.id,
    required this.eventId,
    required this.status,
    required this.answersLocked,
    required this.registeredAt,
  });

  factory UserRegistrationModel.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegistrationModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RegistrationFormFieldModel {
  final String fieldKey;
  final String label;
  final String fieldType;
  final bool isRequired;
  final List<String>? options;

  const RegistrationFormFieldModel({
    required this.fieldKey,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    this.options,
  });

  factory RegistrationFormFieldModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFormFieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationFormFieldModelToJson(this);
}
