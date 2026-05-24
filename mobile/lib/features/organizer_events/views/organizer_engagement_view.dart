import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/event_shared/models/event_feedback_model.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';

class OrganizerEngagementView extends ConsumerWidget {
  final String eventId;
  final VoidCallback? onBack;

  const OrganizerEngagementView({
    super.key,
    required this.eventId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(organizerEventQuestionsProvider(eventId));
    final feedbacksState = ref.watch(organizerEventFeedbacksProvider(eventId));
    final summaryState = ref.watch(
      organizerEventFeedbackSummaryProvider(eventId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Câu hỏi và feedback',
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theo dõi câu hỏi, rating và góp ý của người tham gia.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    summaryState.when(
                      loading: () => const AppLoadingState(
                        height: 96,
                        padding: EdgeInsets.zero,
                      ),
                      error: (_, _) => AppErrorState(
                        title: 'Không tải được thống kê feedback',
                        description: 'Vui lòng thử lại sau.',
                        padding: EdgeInsets.zero,
                        onRetry: () => ref.invalidate(
                          organizerEventFeedbackSummaryProvider(eventId),
                        ),
                      ),
                      data: (summary) => _FeedbackSummaryCard(summary),
                    ),
                    const SizedBox(height: 24),
                    Text('Câu hỏi', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 12),
                    questionsState.when(
                      loading: () => const AppLoadingState(
                        height: 180,
                        padding: EdgeInsets.zero,
                      ),
                      error: (_, _) => AppErrorState(
                        title: 'Không tải được câu hỏi',
                        description: 'Vui lòng thử lại sau.',
                        padding: EdgeInsets.zero,
                        onRetry: () => ref.invalidate(
                          organizerEventQuestionsProvider(eventId),
                        ),
                      ),
                      data: (questions) => _QuestionList(questions: questions),
                    ),
                    const SizedBox(height: 24),
                    Text('Feedback', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 12),
                    feedbacksState.when(
                      loading: () => const AppLoadingState(
                        height: 180,
                        padding: EdgeInsets.zero,
                      ),
                      error: (_, _) => AppErrorState(
                        title: 'Không tải được feedback',
                        description: 'Vui lòng thử lại sau.',
                        padding: EdgeInsets.zero,
                        onRetry: () => ref.invalidate(
                          organizerEventFeedbacksProvider(eventId),
                        ),
                      ),
                      data: (feedbacks) => _FeedbackList(feedbacks: feedbacks),
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Quản lý sự kiện',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: GlassIconButton(
                icon: Icons.refresh,
                onPressed: () {
                  ref.invalidate(organizerEventQuestionsProvider(eventId));
                  ref.invalidate(organizerEventFeedbacksProvider(eventId));
                  ref.invalidate(
                    organizerEventFeedbackSummaryProvider(eventId),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSummaryCard extends StatelessWidget {
  final EventFeedbackSummaryModel summary;

  const _FeedbackSummaryCard(this.summary);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: AppTextStyles.headlineMedium,
                ),
                Text(
                  '${summary.total} feedback',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _ratingBreakdown(summary),
            textAlign: TextAlign.right,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingBreakdown(EventFeedbackSummaryModel summary) {
    return List.generate(5, (index) {
      final rating = 5 - index;
      return '$rating sao ${summary.ratingCounts[rating] ?? 0}';
    }).join('\n');
  }
}

class _QuestionList extends StatelessWidget {
  final List<EventQuestionModel> questions;

  const _QuestionList({required this.questions});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const AppSuccessState(
        isEmpty: true,
        emptyIcon: Icons.forum_outlined,
        emptyTitle: 'Chưa có câu hỏi',
        emptyDescription: 'Câu hỏi từ attendee sẽ hiển thị tại đây.',
        emptyPadding: EdgeInsets.zero,
        child: SizedBox.shrink(),
      );
    }

    final visible = [...questions]
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        final aDate = a.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.askedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return Column(
      children: visible.map((question) => _QuestionCard(question)).toList(),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final EventQuestionModel question;

  const _QuestionCard(this.question);

  @override
  Widget build(BuildContext context) {
    final askedAt = question.askedAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              question.isPinned ? Icons.push_pin : Icons.forum_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.isAnswered
                        ? question.answer!
                        : 'Chưa được trả lời • ${question.moderationStatus}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (askedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(askedAt.toLocal()),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.navInactive,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackList extends StatelessWidget {
  final List<EventFeedbackModel> feedbacks;

  const _FeedbackList({required this.feedbacks});

  @override
  Widget build(BuildContext context) {
    if (feedbacks.isEmpty) {
      return const AppSuccessState(
        isEmpty: true,
        emptyIcon: Icons.rate_review_outlined,
        emptyTitle: 'Chưa có feedback',
        emptyDescription: 'Góp ý sau sự kiện sẽ hiển thị tại đây.',
        emptyPadding: EdgeInsets.zero,
        child: SizedBox.shrink(),
      );
    }

    final visible = [...feedbacks]
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return Column(
      children: visible.map((feedback) => _FeedbackCard(feedback)).toList(),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final EventFeedbackModel feedback;

  const _FeedbackCard(this.feedback);

  @override
  Widget build(BuildContext context) {
    final createdAt = feedback.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${feedback.authorName} • ${feedback.rating}/5',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.content.isEmpty
                        ? 'Không có nội dung.'
                        : feedback.content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(createdAt.toLocal()),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.navInactive,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
