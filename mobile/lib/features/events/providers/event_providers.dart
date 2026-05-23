import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/events/models/event_category_model.dart';
import 'package:frontend/features/events/models/event_feedback_model.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_question_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/models/event_room_model.dart';

const _eventsPageSize = 10;

class PaginatedEventsState {
  final List<EventModel> events;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  const PaginatedEventsState({
    required this.events,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PaginatedEventsState.initial(List<EventModel> events) {
    return PaginatedEventsState(
      events: events,
      nextPage: 2,
      hasMore: events.length >= _eventsPageSize,
    );
  }

  PaginatedEventsState copyWith({
    List<EventModel>? events,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) {
    return PaginatedEventsState(
      events: events ?? this.events,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}

class DiscoveryEventsPager extends AsyncNotifier<PaginatedEventsState> {
  final String? category;

  DiscoveryEventsPager(this.category);

  @override
  Future<PaginatedEventsState> build() async {
    final events = await _fetchPage(1);
    return PaginatedEventsState.initial(events);
  }

  Future<void> refreshPage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final events = await _fetchPage(1);
      return PaginatedEventsState.initial(events);
    });
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextEvents = await _fetchPage(current.nextPage);
      state = AsyncData(
        current.copyWith(
          events: [...current.events, ...nextEvents],
          nextPage: current.nextPage + 1,
          hasMore: nextEvents.length >= _eventsPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  Future<List<EventModel>> _fetchPage(int page) {
    final service = ref.read(eventServiceProvider);
    return service.searchEvents(
      page: page,
      pageSize: _eventsPageSize,
      category: category ?? '',
      status: 'active',
    );
  }
}

class OrganizerEventsPager extends AsyncNotifier<PaginatedEventsState> {
  @override
  Future<PaginatedEventsState> build() async {
    final events = await _fetchPage(1);
    return PaginatedEventsState.initial(events);
  }

  Future<void> refreshPage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final events = await _fetchPage(1);
      return PaginatedEventsState.initial(events);
    });
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextEvents = await _fetchPage(current.nextPage);
      state = AsyncData(
        current.copyWith(
          events: [...current.events, ...nextEvents],
          nextPage: current.nextPage + 1,
          hasMore: nextEvents.length >= _eventsPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  Future<List<EventModel>> _fetchPage(int page) {
    final service = ref.read(eventServiceProvider);
    return service.getOrganizerEvents(page: page, pageSize: _eventsPageSize);
  }
}

final discoveryEventsPagerProvider =
    AsyncNotifierProvider.family<
      DiscoveryEventsPager,
      PaginatedEventsState,
      String?
    >((category) => DiscoveryEventsPager(category));

final organizerEventsPagerProvider =
    AsyncNotifierProvider<OrganizerEventsPager, PaginatedEventsState>(
      OrganizerEventsPager.new,
    );

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

final eventRoomsProvider = FutureProvider<List<EventRoomModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getEventRooms();
});

final myEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getEvents(queryParams: {'scope': 'mine'});
});

final organizerEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return service.getOrganizerEvents();
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  eventId,
) async {
  final service = ref.read(eventServiceProvider);
  return service.getEventDetail(eventId);
});

final organizerEventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  eventId,
) async {
  final service = ref.read(eventServiceProvider);
  return service.getOrganizerEventDetail(eventId);
});

final eventRegistrationsProvider =
    FutureProvider.family<List<EventRegistrationModel>, String>((
      ref,
      eventId,
    ) async {
      final service = ref.read(eventServiceProvider);
      return service.getEventRegistrations(eventId: eventId);
    });

final publicEventQuestionsProvider =
    FutureProvider.family<List<EventQuestionModel>, String>((ref, eventId) {
      final service = ref.read(eventServiceProvider);
      return service.getPublicEventQuestions(eventId: eventId);
    });

final organizerEventQuestionsProvider =
    FutureProvider.family<List<EventQuestionModel>, String>((ref, eventId) {
      final service = ref.read(eventServiceProvider);
      return service.getOrganizerEventQuestions(eventId: eventId);
    });

final eventFeedbacksProvider =
    FutureProvider.family<List<EventFeedbackModel>, String>((ref, eventId) {
      final service = ref.read(eventServiceProvider);
      return service.getEventFeedbacks(eventId: eventId);
    });

final eventFeedbackSummaryProvider =
    FutureProvider.family<EventFeedbackSummaryModel, String>((ref, eventId) {
      final service = ref.read(eventServiceProvider);
      return service.getEventFeedbackSummary(eventId: eventId);
    });
