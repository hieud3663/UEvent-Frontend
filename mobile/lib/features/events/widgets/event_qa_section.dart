// File: lib/features/events/widgets/event_qa_section.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/features/events/models/event_question_model.dart';

/// Q&A section: header with "Ask Question" button + list of questions.
class EventQaSection extends StatelessWidget {
  final List<EventQuestionModel> questions;
  final int totalCount;
  final VoidCallback? onAskQuestion;
  final VoidCallback? onViewAll;

  const EventQaSection({
    super.key,
    required this.questions,
    this.totalCount = 0,
    this.onAskQuestion,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Questions & Answers', style: AppTextStyles.headlineMedium),
            GestureDetector(
              onTap: onAskQuestion,
              child: Text(
                'Ask Question',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Question tiles
        ...questions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuestionTile(question: q),
            )),
        // View All button
        if (totalCount > questions.length)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: Text(
                'View all $totalCount questions',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final EventQuestionModel question;

  const _QuestionTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.question,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (question.isAnswered) ...[
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(width: 24),
                  Container(
                    width: 2,
                    color: AppColors.outline,
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.answer!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        if (question.answeredBy != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Answered by ${question.answeredBy} • ${question.timeAgo}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'No answers yet. Be the first to answer!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
