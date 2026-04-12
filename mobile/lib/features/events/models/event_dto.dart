import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_dto.freezed.dart';
part 'event_dto.g.dart';

@freezed
class CategoryDTO with _$CategoryDTO {
  const factory CategoryDTO({
    required String id,
    required String name,
    required String slug,
    String? icon,
    String? color,
  }) = _CategoryDTO;

  factory CategoryDTO.fromJson(Map<String, dynamic> json) =>
      _$CategoryDTOFromJson(json);
}

@freezed
class LocationDTO with _$LocationDTO {
  const factory LocationDTO({
    required String id,
    required String type, // 'room', 'building', 'campus', or 'string' for location_snapshot
    required String name,
    String? address,
    int? capacity,
  }) = _LocationDTO;

  factory LocationDTO.fromJson(Map<String, dynamic> json) =>
      _$LocationDTOFromJson(json);
}

@freezed
class EventDTO with _$EventDTO {
  const factory EventDTO({
    required String id,
    required String title,
    required String slug,
    required String description,
    required String status,
    required CategoryDTO category,
    required DateTime startAt,
    required DateTime endAt,
    LocationDTO? location,
    String? locationSnapshot,
    int? maxCapacity,
    String? coverImageUrl,
    DateTime? registrationOpenAt,
    DateTime? registrationCloseAt,
    DateTime? cancellationDeadlineAt,
    String? deepLink,
  }) = _EventDTO;

  factory EventDTO.fromJson(Map<String, dynamic> json) =>
      _$EventDTOFromJson(json);
}
