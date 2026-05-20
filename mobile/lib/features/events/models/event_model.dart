// File: lib/models/event_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

/// Data class representing an Event across Home, Discovery, Profile screens.
@JsonSerializable(fieldRename: FieldRename.snake)
class EventModel {
  final String id;
  final String title;
  final String? slug;
  @JsonKey(name: 'cover_image_url')
  final String imageUrl;
  final String location;
  @JsonKey(name: 'start_at')
  final DateTime startDate;
  @JsonKey(name: 'end_at')
  final DateTime? endDate;
  @JsonKey(name: 'registration_open_at')
  final DateTime? registrationOpenAt;
  @JsonKey(name: 'registration_close_at')
  final DateTime? registrationCloseAt;
  @JsonKey(name: 'cancellation_deadline_at')
  final DateTime? cancellationDeadlineAt;
  final String? timeRange;
  final String? category;
  @JsonKey(unknownEnumValue: EventVisibility.public)
  final EventVisibility visibility;
  @JsonKey(unknownEnumValue: EventStatus.active)
  final EventStatus status;
  final String? description;
  @JsonKey(name: 'max_capacity')
  final int? guestCount;
  @JsonKey(name: 'deep_link')
  final String? deepLink;

  /// Whether the current user is the organizer/creator of this event.
  /// true = user created this event, false = user is attending/discovering.
  final bool isOrganizer;

  const EventModel({
    required this.id,
    required this.title,
    this.slug,
    required this.imageUrl,
    required this.location,
    required this.startDate,
    this.endDate,
    this.registrationOpenAt,
    this.registrationCloseAt,
    this.cancellationDeadlineAt,
    this.timeRange,
    this.category,
    this.visibility = EventVisibility.public,
    this.status = EventStatus.active,
    this.description,
    this.guestCount,
    this.deepLink,
    this.isOrganizer = false,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? imageUrl,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationOpenAt,
    DateTime? registrationCloseAt,
    DateTime? cancellationDeadlineAt,
    String? timeRange,
    String? category,
    EventVisibility? visibility,
    EventStatus? status,
    String? description,
    int? guestCount,
    String? deepLink,
    bool? isOrganizer,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationOpenAt: registrationOpenAt ?? this.registrationOpenAt,
      registrationCloseAt: registrationCloseAt ?? this.registrationCloseAt,
      cancellationDeadlineAt:
          cancellationDeadlineAt ?? this.cancellationDeadlineAt,
      timeRange: timeRange ?? this.timeRange,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      description: description ?? this.description,
      guestCount: guestCount ?? this.guestCount,
      deepLink: deepLink ?? this.deepLink,
      isOrganizer: isOrganizer ?? this.isOrganizer,
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      imageUrl: json['cover_image_url'] as String? ?? '',
      location:
          json['location'] as String? ??
          json['location_snapshot'] as String? ??
          '',
      startDate: DateTime.parse(json['start_at'] as String),
      endDate: _parseNullableDateTime(json['end_at']),
      registrationOpenAt: _parseNullableDateTime(json['registration_open_at']),
      registrationCloseAt: _parseNullableDateTime(
        json['registration_close_at'],
      ),
      cancellationDeadlineAt: _parseNullableDateTime(
        json['cancellation_deadline_at'],
      ),
      timeRange: json['time_range'] as String?,
      category: _parseCategoryName(category),
      visibility: _parseVisibility(json['visibility']),
      status: _parseStatus(json['status']),
      description: json['description'] as String?,
      guestCount: (json['max_capacity'] as num?)?.toInt(),
      deepLink: json['deep_link'] as String?,
      isOrganizer: json['is_organizer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$EventModelToJson(this);
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.parse(value);
}

String? _parseCategoryName(dynamic value) {
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    return value['name'] as String? ?? value['slug'] as String?;
  }
  return null;
}

EventVisibility _parseVisibility(dynamic value) {
  if (value is String) {
    for (final visibility in EventVisibility.values) {
      if (visibility.name == value) return visibility;
    }
  }
  return EventVisibility.public;
}

EventStatus _parseStatus(dynamic value) {
  if (value is String) {
    for (final status in EventStatus.values) {
      if (status.name == value) return status;
    }
  }
  return EventStatus.active;
}

enum EventVisibility { public, private }

enum EventStatus { active, draft, finished, cancelled }
