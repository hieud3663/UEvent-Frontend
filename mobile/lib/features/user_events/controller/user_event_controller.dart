import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';

final userEventRegistrationControllerProvider =
    AsyncNotifierProvider<UserEventRegistrationController, void>(
      UserEventRegistrationController.new,
    );

final userEventEngagementControllerProvider =
    AsyncNotifierProvider<UserEventEngagementController, void>(
      UserEventEngagementController.new,
    );

class UserEventRegistrationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<EventRegistrationModel?> registerEvent({
    required String eventId,
    List<EventRegistrationAnswerModel> answers = const [],
  }) async {
    state = const AsyncLoading();

    EventRegistrationModel? registration;
    final result = await AsyncValue.guard(() async {
      registration = await ref
          .read(userEventRepositoryProvider)
          .registerEvent(eventId: eventId, answers: answers);

      ref.invalidate(userEventDetailProvider(eventId));
      ref.invalidate(userMyEventsProvider);
    });

    state = result;
    return result.hasValue ? registration : null;
  }
}

class UserEventEngagementController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createQuestion({
    required String eventId,
    required String questionText,
    required bool isAnonymous,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(userEventRepositoryProvider)
          .createEventQuestion(
            eventId: eventId,
            questionText: questionText,
            isAnonymous: isAnonymous,
          );

      ref.invalidate(userPublicEventQuestionsProvider(eventId));
    });

    state = result;
    return result.hasValue;
  }
}
