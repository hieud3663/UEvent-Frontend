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
}

enum TicketStatus { upcoming, past, cancelled }
