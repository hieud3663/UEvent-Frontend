import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_feedback_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/event_shared/models/event_room_model.dart';
import 'package:frontend/features/organizer_events/models/check_in_model.dart';
import 'package:frontend/features/organizer_events/repositories/organizer_event_repository.dart';
import 'package:frontend/features/organizer_events/services/organizer_event_service.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';

const _eventsPageSize = 10;

final organizerEventServiceProvider = Provider<OrganizerEventService>(
  (ref) => OrganizerEventService(ref.read(apiClientProvider)),
);

final organizerEventRepositoryProvider = Provider<OrganizerEventRepository>(
  (ref) =>
      OrganizerEventRepositoryImpl(ref.read(organizerEventServiceProvider)),
);

class PaginatedOrganizerEventsState {
  final List<EventModel> events;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  const PaginatedOrganizerEventsState({
    required this.events,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  factory PaginatedOrganizerEventsState.initial(List<EventModel> events) {
    return PaginatedOrganizerEventsState(
      events: events,
      nextPage: 2,
      hasMore: events.length >= _eventsPageSize,
    );
  }

  PaginatedOrganizerEventsState copyWith({
    List<EventModel>? events,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) {
    return PaginatedOrganizerEventsState(
      events: events ?? this.events,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}

class OrganizerEventsPager
    extends AsyncNotifier<PaginatedOrganizerEventsState> {
  @override
  Future<PaginatedOrganizerEventsState> build() async {
    final events = await _fetchPage(1);
    return PaginatedOrganizerEventsState.initial(events);
  }

  Future<void> refreshPage() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final events = await _fetchPage(1);
      return PaginatedOrganizerEventsState.initial(events);
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
    final repository = ref.read(organizerEventRepositoryProvider);
    return repository.getOrganizerEvents(page: page, pageSize: _eventsPageSize);
  }
}

final organizerEventsPagerProvider =
    AsyncNotifierProvider<OrganizerEventsPager, PaginatedOrganizerEventsState>(
      OrganizerEventsPager.new,
    );

final organizerEventRoomsProvider = FutureProvider<List<EventRoomModel>>((
  ref,
) async {
  final repository = ref.read(organizerEventRepositoryProvider);
  return repository.getEventRooms();
});

final organizerEventCategoriesProvider =
    FutureProvider<List<EventCategoryModel>>((ref) {
      return ref.watch(userEventCategoriesProvider.future);
    });

final organizerEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.read(organizerEventRepositoryProvider);
  return repository.getOrganizerEvents();
});

final organizerEventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  eventId,
) async {
  final repository = ref.read(organizerEventRepositoryProvider);
  return repository.getOrganizerEventDetail(eventId);
});

final organizerEventRegistrationsProvider =
    FutureProvider.family<List<EventRegistrationModel>, String>((
      ref,
      eventId,
    ) async {
      final repository = ref.read(organizerEventRepositoryProvider);
      return repository.getEventRegistrations(eventId: eventId);
    });

final organizerEventOrganizersProvider =
    FutureProvider.family<List<EventOrganizerMemberModel>, String>((
      ref,
      eventId,
    ) async {
      final repository = ref.read(organizerEventRepositoryProvider);
      return repository.getEventOrganizers(eventId: eventId);
    });

final organizerCheckInLogsProvider =
    FutureProvider.family<List<CheckInLogModel>, String>((ref, eventId) async {
      final repository = ref.read(organizerEventRepositoryProvider);
      return repository.getCheckInLogs(eventId: eventId);
    });

final organizerEventQuestionsProvider =
    FutureProvider.family<List<EventQuestionModel>, String>((ref, eventId) {
      final repository = ref.read(organizerEventRepositoryProvider);
      return repository.getOrganizerEventQuestions(eventId: eventId);
    });

final organizerEventFeedbacksProvider =
    FutureProvider.family<List<EventFeedbackModel>, String>((ref, eventId) {
      return ref.watch(userEventFeedbacksProvider(eventId).future);
    });

final organizerEventFeedbackSummaryProvider =
    FutureProvider.family<EventFeedbackSummaryModel, String>((ref, eventId) {
      return ref.watch(userEventFeedbackSummaryProvider(eventId).future);
    });
