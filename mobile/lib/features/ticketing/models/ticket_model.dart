// File: lib/features/ticketing/models/ticket_model.dart

/// Data class representing a registered ticket for an event.
class TicketModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventImageUrl;
  final String date;
  final String timeRange;
  final String location;
  final String ticketCode;
  final String section;
  final String? row;
  final String? seat;
  final String orderId;
  final String? guestType;
  final TicketStatus status;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventImageUrl,
    required this.date,
    required this.timeRange,
    required this.location,
    required this.ticketCode,
    required this.section,
    this.row,
    this.seat,
    required this.orderId,
    this.guestType,
    this.status = TicketStatus.upcoming,
  });

  TicketModel copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? eventImageUrl,
    String? date,
    String? timeRange,
    String? location,
    String? ticketCode,
    String? section,
    String? row,
    String? seat,
    String? orderId,
    String? guestType,
    TicketStatus? status,
  }) {
    return TicketModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      eventImageUrl: eventImageUrl ?? this.eventImageUrl,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      location: location ?? this.location,
      ticketCode: ticketCode ?? this.ticketCode,
      section: section ?? this.section,
      row: row ?? this.row,
      seat: seat ?? this.seat,
      orderId: orderId ?? this.orderId,
      guestType: guestType ?? this.guestType,
      status: status ?? this.status,
    );
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final String rawStatus = (json['status'] ?? 'upcoming').toString();
    final TicketStatus status = TicketStatus.values.firstWhere(
      (e) => e.name == rawStatus,
      orElse: () => TicketStatus.upcoming,
    );

    return TicketModel(
      id: (json['id'] ?? json['ticketCode'] ?? '').toString(),
      eventId: (json['eventId'] ?? json['event_id'] ?? '').toString(),
      eventName: (json['eventName'] ?? json['event_name'] ?? 'Untitled event').toString(),
      eventImageUrl: (json['eventImageUrl'] ?? json['event_image_url'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      timeRange: (json['timeRange'] ?? json['time_range'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      ticketCode: (json['ticketCode'] ?? json['ticket_code'] ?? '').toString(),
      section: (json['section'] ?? 'General').toString(),
      row: json['row']?.toString(),
      seat: json['seat']?.toString(),
      orderId: (json['orderId'] ?? json['order_id'] ?? '').toString(),
      guestType: json['guestType']?.toString(),
      status: status,
    );
  }
}

enum TicketStatus { upcoming, past, cancelled }

class UserRegistrationModel {
  final String id;
  final String eventId;
  final String status;
  final bool answersLocked;
  final DateTime registeredAt;

  const UserRegistrationModel({
    required this.id,
    required this.eventId,
    required this.status,
    required this.answersLocked,
    required this.registeredAt,
  });

  factory UserRegistrationModel.fromJson(Map<String, dynamic> json) {
    return UserRegistrationModel(
      id: (json['id'] ?? '').toString(),
      eventId: (json['eventId'] ?? json['event_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      answersLocked: json['answersLocked'] as bool? ?? false,
      registeredAt: DateTime.tryParse((json['registeredAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class RegistrationFormFieldModel {
  final String fieldKey;
  final String label;
  final String fieldType;
  final bool isRequired;
  final List<String>? options;

  const RegistrationFormFieldModel({
    required this.fieldKey,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    this.options,
  });
}
