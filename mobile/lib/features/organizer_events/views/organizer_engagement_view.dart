import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_question_list.dart';

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
                      data: (questions) => OrganizerQuestionList(
                        eventId: eventId,
                        questions: questions,
                      ),
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
