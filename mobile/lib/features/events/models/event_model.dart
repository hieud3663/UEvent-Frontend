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
      cancellationDeadlineAt: cancellationDeadlineAt ?? this.cancellationDeadlineAt,
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
    final dynamic locationRaw = json['location'];
    final String resolvedLocation =
      locationRaw is String
        ? locationRaw
        : (locationRaw?['name'] as String? ??
          (json['locationSnapshot'] as String? ??
            json['location_snapshot'] as String? ??
            'Unknown location'));

    final dynamic categoryRaw = json['category'];
    final String? categoryName = categoryRaw is String
        ? categoryRaw
        : categoryRaw?['name']?.toString();

    final String? imageUrl =
      (json['imageUrl'] ?? json['coverImageUrl'] ?? json['cover_image_url'])
        as String?;
    final normalized = Map<String, dynamic>.from(json);
    normalized['cover_image_url'] ??= imageUrl;
    normalized['location'] = resolvedLocation;
    normalized['category'] = categoryName;
    normalized['start_at'] ??= normalized['startDate'] ?? normalized['startAt'];
    normalized['end_at'] ??= normalized['endDate'] ?? normalized['endAt'];
    normalized['registration_open_at'] ??= normalized['registrationOpenAt'];
    normalized['registration_close_at'] ??= normalized['registrationCloseAt'];
    normalized['cancellation_deadline_at'] ??= normalized['cancellationDeadlineAt'];
    normalized['max_capacity'] ??= normalized['guestCount'] ?? normalized['maxCapacity'];
    normalized['deep_link'] ??= normalized['deepLink'];
    normalized['is_organizer'] ??= normalized['isOrganizer'];

    return _$EventModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$EventModelToJson(this);
}

enum EventVisibility { public, private }

enum EventStatus { active, draft, finished, cancelled }
