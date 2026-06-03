import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/event_shared/models/event_registration_model.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
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

    try {
      final registration = await ref
          .read(userEventRepositoryProvider)
          .registerEvent(eventId: eventId, answers: answers);

      await _refreshEventDetail(eventId);
      ref.invalidate(userMyEventsProvider);
      ref.invalidate(userRegisteredEventsProvider);
      ref.invalidate(profileOverviewProvider);
      state = const AsyncData(null);
      return registration;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<bool> unregisterEvent({required String eventId}) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(userEventRepositoryProvider)
          .unregisterCurrentUserFromEvent(eventId: eventId);

      await _refreshEventDetail(eventId);
      ref.invalidate(userMyEventsProvider);
      ref.invalidate(userRegisteredEventsProvider);
      ref.invalidate(profileOverviewProvider);
    });

    state = result;
    return result.hasValue;
  }

  Future<void> _refreshEventDetail(String eventId) async {
    ref.invalidate(userEventDetailProvider(eventId));
    try {
      await ref.read(userEventDetailProvider(eventId).future);
    } catch (_) {
      // Registration mutations should keep their own result even if the
      // follow-up detail refresh fails.
    }
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

  Future<bool> replyToQuestion({
    required String eventId,
    required String questionId,
    required String content,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      await ref
          .read(userEventRepositoryProvider)
          .createQuestionReply(questionId: questionId, content: content);

      ref.invalidate(userPublicEventQuestionsProvider(eventId));
    });

    state = result;
    return result.hasValue;
  }
}
