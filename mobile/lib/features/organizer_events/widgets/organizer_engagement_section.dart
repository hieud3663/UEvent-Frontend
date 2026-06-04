import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_question_list_card.dart';

class OrganizerEngagementSection extends ConsumerWidget {
  final String eventId;

  const OrganizerEngagementSection({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(organizerEventQuestionsProvider(eventId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hỏi đáp', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        questionsState.when(
          loading: () =>
              const AppLoadingState(height: 120, padding: EdgeInsets.zero),
          error: (_, _) => AppErrorState(
            title: 'Không tải được câu hỏi',
            description: 'Vui lòng thử lại sau.',
            padding: EdgeInsets.zero,
            onRetry: () =>
                ref.invalidate(organizerEventQuestionsProvider(eventId)),
          ),
          data: (questions) =>
              OrganizerQuestionListCard(eventId: eventId, questions: questions),
        ),
      ],
    );
  }
}
