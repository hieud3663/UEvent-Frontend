// File: lib/features/ticketing/models/ticket_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'ticket_model.g.dart';

/// Data class representing a registered ticket for an event.
@JsonSerializable(fieldRename: FieldRename.snake)
class TicketModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventImageUrl;
  final String? qrPayload;
  final DateTime? validFrom;
  final DateTime? validTo;
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
    required this.eventId,
    required this.eventName,
    required this.eventImageUrl,
    this.qrPayload,
    this.validFrom,
    this.validTo,
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
    String? eventId,
    String? eventName,
    String? eventImageUrl,
    String? qrPayload,
    DateTime? validFrom,
    DateTime? validTo,
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
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      qrPayload: qrPayload ?? this.qrPayload,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
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
}

enum TicketStatus { upcoming, past, cancelled }

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
