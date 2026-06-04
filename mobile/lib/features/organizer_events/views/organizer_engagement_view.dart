import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_question_thread.dart';

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
                      'Danh sách câu hỏi',
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theo dõi và trả lời câu hỏi từ người tham gia.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      data: (questions) =>
                          _QuestionList(eventId: eventId, questions: questions),
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionList extends StatelessWidget {
  final String eventId;
  final List<EventQuestionModel> questions;

  const _QuestionList({required this.eventId, required this.questions});

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
    final answeredCount = visible
        .where((question) => question.isAnswered)
        .length;
    final pendingCount = visible.length - answeredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionStatsRow(
          totalCount: visible.length,
          answeredCount: answeredCount,
          pendingCount: pendingCount,
        ),
        const SizedBox(height: 16),
        Text('Câu hỏi mới nhất', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 14),
        ...visible.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              borderRadius: 22,
              child: OrganizerQuestionThread(
                eventId: eventId,
                question: question,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionStatsRow extends StatelessWidget {
  final int totalCount;
  final int answeredCount;
  final int pendingCount;

  const _QuestionStatsRow({
    required this.totalCount,
    required this.answeredCount,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuestionStatCard(
            label: 'Tổng câu hỏi',
            value: '$totalCount',
            icon: Icons.forum_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuestionStatCard(
            label: 'Đã trả lời',
            value: '$answeredCount',
            icon: Icons.mark_chat_read_outlined,
            color: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuestionStatCard(
            label: 'Chờ xử lý',
            value: '$pendingCount',
            icon: Icons.pending_actions_outlined,
            color: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }
}

class _QuestionStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuestionStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
