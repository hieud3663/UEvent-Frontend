// File: lib/models/event_model.dart

/// Data class representing an Event across Home, Discovery, Profile screens.
class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final String? timeRange;
  final String? category;
  final EventVisibility visibility;
  final EventStatus status;
  final String? description;
  final int? guestCount;

  /// Whether the current user is the organizer/creator of this event.
  /// true = user created this event, false = user is attending/discovering.
  final bool isOrganizer;

  const EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.startDate,
    this.endDate,
    this.timeRange,
    this.category,
    this.visibility = EventVisibility.public,
    this.status = EventStatus.active,
    this.description,
    this.guestCount,
    this.isOrganizer = false,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? timeRange,
    String? category,
    EventVisibility? visibility,
    EventStatus? status,
    String? description,
    int? guestCount,
    bool? isOrganizer,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timeRange: timeRange ?? this.timeRange,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      description: description ?? this.description,
      guestCount: guestCount ?? this.guestCount,
      isOrganizer: isOrganizer ?? this.isOrganizer,
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final dynamic locationRaw = json['location'];
    final String resolvedLocation =
        locationRaw is String ? locationRaw : (locationRaw?['name'] as String? ?? (json['locationSnapshot'] as String? ?? 'Unknown location'));

    final String? imageUrl = (json['imageUrl'] ?? json['coverImageUrl']) as String?;
    final String? categoryName = json['category'] is String
        ? json['category'] as String
        : (json['category']?['name'] as String?);

    final String? startRaw = (json['startDate'] ?? json['startAt']) as String?;
    final String? endRaw = (json['endDate'] ?? json['endAt']) as String?;

    return EventModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      imageUrl: imageUrl ?? '',
      location: resolvedLocation,
      startDate: DateTime.tryParse(startRaw ?? '') ?? DateTime.now(),
      endDate: endRaw != null
          ? DateTime.tryParse(endRaw)
          : null,
      timeRange: json['timeRange'] as String?,
      category: categoryName,
      visibility: EventVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => EventVisibility.public,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.active,
      ),
      description: json['description'] as String?,
      guestCount: json['guestCount'] as int? ?? json['maxCapacity'] as int?,
      isOrganizer: json['isOrganizer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'timeRange': timeRange,
      'category': category,
      'visibility': visibility.name,
      'status': status.name,
      'description': description,
      'guestCount': guestCount,
      'isOrganizer': isOrganizer,
    };
  }
}

enum EventVisibility { public, private }

enum EventStatus { active, draft, finished, cancelled }
