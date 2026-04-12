// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryDTO _$CategoryDTOFromJson(Map<String, dynamic> json) => _CategoryDTO(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$CategoryDTOToJson(_CategoryDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'icon': instance.icon,
      'color': instance.color,
    };

_LocationDTO _$LocationDTOFromJson(Map<String, dynamic> json) => _LocationDTO(
  id: json['id'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
);

Map<String, dynamic> _$LocationDTOToJson(_LocationDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'address': instance.address,
      'capacity': instance.capacity,
    };

_EventDTO _$EventDTOFromJson(Map<String, dynamic> json) => _EventDTO(
  id: json['id'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String,
  status: json['status'] as String,
  category: CategoryDTO.fromJson(json['category'] as Map<String, dynamic>),
  startAt: DateTime.parse(json['start_at'] as String),
  endAt: DateTime.parse(json['end_at'] as String),
  location: json['location'] == null
      ? null
      : LocationDTO.fromJson(json['location'] as Map<String, dynamic>),
  locationSnapshot: json['location_snapshot'] as String?,
  maxCapacity: (json['max_capacity'] as num?)?.toInt(),
  coverImageUrl: json['cover_image_url'] as String?,
  registrationOpenAt: json['registration_open_at'] == null
      ? null
      : DateTime.parse(json['registration_open_at'] as String),
  registrationCloseAt: json['registration_close_at'] == null
      ? null
      : DateTime.parse(json['registration_close_at'] as String),
  cancellationDeadlineAt: json['cancellation_deadline_at'] == null
      ? null
      : DateTime.parse(json['cancellation_deadline_at'] as String),
  deepLink: json['deep_link'] as String?,
);

Map<String, dynamic> _$EventDTOToJson(_EventDTO instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'description': instance.description,
  'status': instance.status,
  'category': instance.category.toJson(),
  'start_at': instance.startAt.toIso8601String(),
  'end_at': instance.endAt.toIso8601String(),
  'location': instance.location?.toJson(),
  'location_snapshot': instance.locationSnapshot,
  'max_capacity': instance.maxCapacity,
  'cover_image_url': instance.coverImageUrl,
  'registration_open_at': instance.registrationOpenAt?.toIso8601String(),
  'registration_close_at': instance.registrationCloseAt?.toIso8601String(),
  'cancellation_deadline_at': instance.cancellationDeadlineAt
      ?.toIso8601String(),
  'deep_link': instance.deepLink,
};
