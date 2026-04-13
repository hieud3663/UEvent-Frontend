// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => TicketModel(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  eventName: json['event_name'] as String,
  eventImageUrl: json['event_image_url'] as String,
  qrPayload: json['qr_payload'] as String?,
  validFrom: json['valid_from'] == null
      ? null
      : DateTime.parse(json['valid_from'] as String),
  validTo: json['valid_to'] == null
      ? null
      : DateTime.parse(json['valid_to'] as String),
  date: json['date'] as String,
  timeRange: json['time_range'] as String,
  location: json['location'] as String,
  ticketCode: json['ticket_code'] as String,
  section: json['section'] as String,
  row: json['row'] as String?,
  seat: json['seat'] as String?,
  orderId: json['order_id'] as String,
  guestType: json['guest_type'] as String?,
  status:
      $enumDecodeNullable(
        _$TicketStatusEnumMap,
        json['status'],
        unknownValue: TicketStatus.upcoming,
      ) ??
      TicketStatus.upcoming,
);

Map<String, dynamic> _$TicketModelToJson(TicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'event_name': instance.eventName,
      'event_image_url': instance.eventImageUrl,
      'qr_payload': instance.qrPayload,
      'valid_from': instance.validFrom?.toIso8601String(),
      'valid_to': instance.validTo?.toIso8601String(),
      'date': instance.date,
      'time_range': instance.timeRange,
      'location': instance.location,
      'ticket_code': instance.ticketCode,
      'section': instance.section,
      'row': instance.row,
      'seat': instance.seat,
      'order_id': instance.orderId,
      'guest_type': instance.guestType,
      'status': _$TicketStatusEnumMap[instance.status]!,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.upcoming: 'upcoming',
  TicketStatus.past: 'past',
  TicketStatus.cancelled: 'cancelled',
};

UserRegistrationModel _$UserRegistrationModelFromJson(
  Map<String, dynamic> json,
) => UserRegistrationModel(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  status: json['status'] as String,
  answersLocked: json['answers_locked'] as bool,
  registeredAt: DateTime.parse(json['registered_at'] as String),
);

Map<String, dynamic> _$UserRegistrationModelToJson(
  UserRegistrationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'status': instance.status,
  'answers_locked': instance.answersLocked,
  'registered_at': instance.registeredAt.toIso8601String(),
};

RegistrationFormFieldModel _$RegistrationFormFieldModelFromJson(
  Map<String, dynamic> json,
) => RegistrationFormFieldModel(
  fieldKey: json['field_key'] as String,
  label: json['label'] as String,
  fieldType: json['field_type'] as String,
  isRequired: json['is_required'] as bool,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RegistrationFormFieldModelToJson(
  RegistrationFormFieldModel instance,
) => <String, dynamic>{
  'field_key': instance.fieldKey,
  'label': instance.label,
  'field_type': instance.fieldType,
  'is_required': instance.isRequired,
  'options': instance.options,
};
