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
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      timeRange: json['timeRange'] as String?,
      category: json['category'] as String?,
      visibility: EventVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => EventVisibility.public,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.active,
      ),
      description: json['description'] as String?,
      guestCount: json['guestCount'] as int?,
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
    };
  }
}

enum EventVisibility { public, private }

enum EventStatus { active, draft, finished, cancelled }
