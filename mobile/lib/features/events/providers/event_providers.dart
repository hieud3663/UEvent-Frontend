import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/events/models/event_model.dart';

final discoveryEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getEvents();
});

final myEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getEvents(queryParams: {'scope': 'mine'});
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, eventId) async {
  final service = ref.read(eventServiceProvider);
  return service.getEventDetail(eventId);
});
