import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_dto.freezed.dart';
part 'ticket_dto.g.dart';

@freezed
class TicketDTO with _$TicketDTO {
  const factory TicketDTO({
    required String ticketCode,
    required String qrPayload,
    required DateTime validFrom,
    required DateTime validTo,
    required String status,
  }) = _TicketDTO;

  factory TicketDTO.fromJson(Map<String, dynamic> json) =>
      _$TicketDTOFromJson(json);
}

@freezed
class UserRegistrationDTO with _$UserRegistrationDTO {
  const factory UserRegistrationDTO({
    required String id,
    required String eventId,
    required String status,
    required bool answersLocked,
    required DateTime registeredAt,
  }) = _UserRegistrationDTO;

  factory UserRegistrationDTO.fromJson(Map<String, dynamic> json) =>
      _$UserRegistrationDTOFromJson(json);
}

@freezed
class RegistrationFormFieldDTO with _$RegistrationFormFieldDTO {
  const factory RegistrationFormFieldDTO({
    required String fieldKey,
    required String label,
    required String fieldType,
    required bool isRequired,
    List<String>? optionsJson,
  }) = _RegistrationFormFieldDTO;

  factory RegistrationFormFieldDTO.fromJson(Map<String, dynamic> json) =>
      _$RegistrationFormFieldDTOFromJson(json);
}
