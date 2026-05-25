import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_feedback_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/user_events/repositories/user_event_repository.dart';
import 'package:frontend/features/user_events/services/user_event_service.dart';

const _eventsPageSize = 10;

final userEventServiceProvider = Provider<UserEventService>(
  (ref) => UserEventService(ref.read(apiClientProvider)),
);

final userEventRepositoryProvider = Provider<UserEventRepository>(
  (ref) => UserEventRepositoryImpl(ref.read(userEventServiceProvider)),
);

class PaginatedUserEventsState {
  final List<EventModel> events;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  const PaginatedUserEventsState({
    required this.events,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PaginatedUserEventsState.initial(List<EventModel> events) {
    return PaginatedUserEventsState(
      events: events,
      nextPage: 2,
      hasMore: events.length >= _eventsPageSize,
    );
  }

  PaginatedUserEventsState copyWith({
    List<EventModel>? events,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) {
    return PaginatedUserEventsState(
      events: events ?? this.events,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}

class UserDiscoveryEventsPager extends AsyncNotifier<PaginatedUserEventsState> {
  final String? category;

  UserDiscoveryEventsPager(this.category);

  @override
  Future<PaginatedUserEventsState> build() async {
    final events = await _fetchPage(1);
    return PaginatedUserEventsState.initial(events);
  }

  Future<void> refreshPage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final events = await _fetchPage(1);
      return PaginatedUserEventsState.initial(events);
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
    final repository = ref.read(userEventRepositoryProvider);
    return repository.searchEvents(
      page: page,
      pageSize: _eventsPageSize,
      category: category ?? '',
      status: 'active',
    );
  }
}

final userDiscoveryEventsPagerProvider =
    AsyncNotifierProvider.family<
      UserDiscoveryEventsPager,
      PaginatedUserEventsState,
      String?
    >((category) => UserDiscoveryEventsPager(category));

final userDiscoverySearchEventsProvider =
    FutureProvider.family<List<EventModel>, String?>((ref, category) async {
      final repository = ref.read(userEventRepositoryProvider);
      return repository.searchEvents(
        category: category ?? '',
        status: 'active',
        pageSize: 10,
      );
    });

final userDiscoveryEventsProvider = FutureProvider<List<EventModel>>((
  ref,
) async {
  return ref.watch(userDiscoverySearchEventsProvider(null).future);
});

final userEventCategoriesProvider = FutureProvider<List<EventCategoryModel>>((
  ref,
) async {
  final repository = ref.read(userEventRepositoryProvider);
  return repository.getEventCategories();
});

final userMyEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.read(userEventRepositoryProvider);
  return repository.getEvents(queryParams: {'scope': 'mine'});
});

final userRegisteredEventsProvider = FutureProvider<List<EventModel>>((
  ref,
) async {
  final repository = ref.read(userEventRepositoryProvider);
  return repository.getMyRegisteredEvents();
});

final userEventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  eventId,
) async {
  final repository = ref.read(userEventRepositoryProvider);
  return repository.getEventDetail(eventId);
});

final userPublicEventQuestionsProvider =
    FutureProvider.family<List<EventQuestionModel>, String>((ref, eventId) {
      final repository = ref.read(userEventRepositoryProvider);
      return repository.getPublicEventQuestions(eventId: eventId);
    });

final userEventFeedbacksProvider =
    FutureProvider.family<List<EventFeedbackModel>, String>((ref, eventId) {
      final repository = ref.read(userEventRepositoryProvider);
      return repository.getEventFeedbacks(eventId: eventId);
    });

final userEventFeedbackSummaryProvider =
    FutureProvider.family<EventFeedbackSummaryModel, String>((ref, eventId) {
      final repository = ref.read(userEventRepositoryProvider);
      return repository.getEventFeedbackSummary(eventId: eventId);
    });
