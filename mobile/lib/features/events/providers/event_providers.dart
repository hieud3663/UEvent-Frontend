import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_model.dart';

final discoverySearchEventsProvider =
    FutureProvider.family<List<EventModel>, String?>((ref, category) async {
      final service = ref.read(eventServiceProvider);
      return service.searchEvents(
        category: category ?? '',
        status: 'active',
        pageSize: 10,
      );
    });

final discoveryEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  return ref.watch(discoverySearchEventsProvider(null).future);
});

final eventCategoriesProvider = FutureProvider<List<EventCategoryModel>>((
  ref,
) async {
  final service = ref.read(eventServiceProvider);
  return service.getEventCategories();
});

final myEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getEvents(queryParams: {'scope': 'mine'});
});

final organizerEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  final events = await service.getEvents(queryParams: {'scope': 'organizer'});
  return events.where((event) => event.isOrganizer).toList();
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  eventId,
) async {
  final service = ref.read(eventServiceProvider);
  return service.getEventDetail(eventId);
});
