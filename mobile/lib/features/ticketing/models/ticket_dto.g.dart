// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketDTO _$TicketDTOFromJson(Map<String, dynamic> json) => _TicketDTO(
  ticketCode: json['ticket_code'] as String,
  qrPayload: json['qr_payload'] as String,
  validFrom: DateTime.parse(json['valid_from'] as String),
  validTo: DateTime.parse(json['valid_to'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$TicketDTOToJson(_TicketDTO instance) =>
    <String, dynamic>{
      'ticket_code': instance.ticketCode,
      'qr_payload': instance.qrPayload,
      'valid_from': instance.validFrom.toIso8601String(),
      'valid_to': instance.validTo.toIso8601String(),
      'status': instance.status,
    };

_UserRegistrationDTO _$UserRegistrationDTOFromJson(Map<String, dynamic> json) =>
    _UserRegistrationDTO(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      status: json['status'] as String,
      answersLocked: json['answers_locked'] as bool,
      registeredAt: DateTime.parse(json['registered_at'] as String),
    );

Map<String, dynamic> _$UserRegistrationDTOToJson(
  _UserRegistrationDTO instance,
) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'status': instance.status,
  'answers_locked': instance.answersLocked,
  'registered_at': instance.registeredAt.toIso8601String(),
};

_RegistrationFormFieldDTO _$RegistrationFormFieldDTOFromJson(
  Map<String, dynamic> json,
) => _RegistrationFormFieldDTO(
  fieldKey: json['field_key'] as String,
  label: json['label'] as String,
  fieldType: json['field_type'] as String,
  isRequired: json['is_required'] as bool,
  optionsJson: (json['options_json'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RegistrationFormFieldDTOToJson(
  _RegistrationFormFieldDTO instance,
) => <String, dynamic>{
  'field_key': instance.fieldKey,
  'label': instance.label,
  'field_type': instance.fieldType,
  'is_required': instance.isRequired,
  'options_json': instance.optionsJson,
};
