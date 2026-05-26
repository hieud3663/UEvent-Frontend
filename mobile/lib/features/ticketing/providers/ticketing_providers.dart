import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';

final upcomingTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final service = ref.read(ticketingServiceProvider);
  return service.getMyTickets(status: 'upcoming');
});

final pastTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final service = ref.read(ticketingServiceProvider);
  return service.getMyTickets(status: 'past');
});

final eventTicketProvider =
    FutureProvider.family<RegistrationTicketModel, String>((
      ref,
      eventId,
    ) async {
      final service = ref.read(ticketingServiceProvider);
      return service.getEventTicket(eventId);
    });
