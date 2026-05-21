class EventRoomModel {
  final String id;
  final String name;
  final String code;
  final int capacity;

  const EventRoomModel({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
  });

  String get displayName => code.isEmpty ? name : '$name ($code)';

  factory EventRoomModel.fromJson(Map<String, dynamic> json) {
    return EventRoomModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    );
  }
}
