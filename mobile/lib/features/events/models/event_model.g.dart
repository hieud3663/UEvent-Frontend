// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
