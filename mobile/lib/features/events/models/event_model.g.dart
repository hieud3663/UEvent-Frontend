// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String?,
  imageUrl: json['cover_image_url'] as String,
  location: json['location'] as String,
  startDate: DateTime.parse(json['start_at'] as String),
  endDate: json['end_at'] == null
      ? null
      : DateTime.parse(json['end_at'] as String),
  registrationOpenAt: json['registration_open_at'] == null
      ? null
      : DateTime.parse(json['registration_open_at'] as String),
  registrationCloseAt: json['registration_close_at'] == null
      ? null
      : DateTime.parse(json['registration_close_at'] as String),
  cancellationDeadlineAt: json['cancellation_deadline_at'] == null
      ? null
      : DateTime.parse(json['cancellation_deadline_at'] as String),
  timeRange: json['time_range'] as String?,
  category: json['category'] as String?,
  visibility:
      $enumDecodeNullable(
        _$EventVisibilityEnumMap,
        json['visibility'],
        unknownValue: EventVisibility.public,
      ) ??
      EventVisibility.public,
  status:
      $enumDecodeNullable(
        _$EventStatusEnumMap,
        json['status'],
        unknownValue: EventStatus.active,
      ) ??
      EventStatus.active,
  description: json['description'] as String?,
  guestCount: (json['max_capacity'] as num?)?.toInt(),
  deepLink: json['deep_link'] as String?,
  isOrganizer: json['is_organizer'] as bool? ?? false,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'cover_image_url': instance.imageUrl,
      'location': instance.location,
      'start_at': instance.startDate.toIso8601String(),
      'end_at': instance.endDate?.toIso8601String(),
      'registration_open_at': instance.registrationOpenAt?.toIso8601String(),
      'registration_close_at': instance.registrationCloseAt?.toIso8601String(),
      'cancellation_deadline_at': instance.cancellationDeadlineAt
          ?.toIso8601String(),
      'time_range': instance.timeRange,
      'category': instance.category,
      'visibility': _$EventVisibilityEnumMap[instance.visibility]!,
      'status': _$EventStatusEnumMap[instance.status]!,
      'description': instance.description,
      'max_capacity': instance.guestCount,
      'deep_link': instance.deepLink,
      'is_organizer': instance.isOrganizer,
    };

const _$EventVisibilityEnumMap = {
  EventVisibility.public: 'public',
  EventVisibility.private: 'private',
};

const _$EventStatusEnumMap = {
  EventStatus.active: 'active',
  EventStatus.draft: 'draft',
  EventStatus.finished: 'finished',
  EventStatus.cancelled: 'cancelled',
};
