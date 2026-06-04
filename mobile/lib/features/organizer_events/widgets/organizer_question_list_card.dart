import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_question_thread.dart';

class OrganizerQuestionListCard extends StatelessWidget {
  final String eventId;
  final List<EventQuestionModel> questions;

  const OrganizerQuestionListCard({
    super.key,
    required this.eventId,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final visible = [...questions]
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final aDate = a.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu hỏi', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text(
              'Chưa có câu hỏi nào.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            ...visible
                .take(4)
                .map(
                  (question) => OrganizerQuestionThread(
                    eventId: eventId,
                    question: question,
                    showTimestamp: false,
                    compact: true,
                  ),
                ),
        ],
      ),
    );
  }
}
