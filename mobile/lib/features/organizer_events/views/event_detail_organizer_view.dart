// File: lib/features/organizer_events/views/event_detail_organizer_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_engagement_section.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_action_buttons.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_description_section.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_hero_image.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_info_section.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_more_actions_sheet.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_stats_section.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_team_section.dart';
import 'package:frontend/features/organizer_events/views/organizer_team_view.dart';

/// Event Detail — Organizer View with Check-in capability.
/// Push navigation (no bottom nav, ← back button).
class EventDetailOrganizerView extends ConsumerWidget {
  final String eventId;
  final EventModel? initialEvent;
  final VoidCallback? onBack;
  final VoidCallback? onCheckIn;
  final VoidCallback? onNotify;
  final VoidCallback? onManage;
  final VoidCallback? onShare;

  const EventDetailOrganizerView({
    super.key,
    required this.eventId,
    this.initialEvent,
    this.onBack,
    this.onCheckIn,
    this.onNotify,
    this.onManage,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(organizerEventDetailProvider(eventId));
    final mutationState = ref.watch(organizerEventMutationControllerProvider);
    final event =
        detailState.whenOrNull(data: (value) => value) ?? initialEvent;

    if (event == null && detailState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null && detailState.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: AppErrorState(
            title: 'Không tải được sự kiện',
            description:
                'Bạn không có quyền tổ chức hoặc sự kiện không tồn tại.',
            onRetry: () => _invalidateEventDetailData(ref),
          ),
        ),
      );
    }

    final resolvedEvent = event!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _refreshEventDetailData(ref),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),

                // ── Hero Image ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventHeroImage(event: resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Category Badge + Title + Meta ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventInfoSection(event: resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Hành động của BTC ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventActionButtons(
                      onNotify: onNotify,
                      onManage: onManage,
                    ),
                  ),
                ),
                if (resolvedEvent.status == EventStatus.draft) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                      ),
                      child: PrimaryButton(
                        label: 'Kích hoạt sự kiện',
                        icon: Icons.publish,
                        isLoading: mutationState.isLoading,
                        onPressed: mutationState.isLoading
                            ? null
                            : () => _activateDraftEvent(context, ref),
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Participant Check-in CTA ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: PrimaryButton(
                      label: 'Check-in người tham gia',
                      icon: Icons.qr_code_2,
                      onPressed: onCheckIn,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Stats Section ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventStatsSection(event: resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Event Description ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventDescriptionSection(
                      event: resolvedEvent,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── BTC Team ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEventTeamSection(
                      event: resolvedEvent,
                      onViewAll: () =>
                          _openOrganizerTeam(context, resolvedEvent.id),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: OrganizerEngagementSection(eventId: eventId),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Chi tiết sự kiện',
              titleStyle: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
              leadingIcon: Icons.chevron_left,
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    Icons.share,
                    onTap: onShare,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 4),
                  _buildCircleButton(
                    Icons.more_vert,
                    onTap: () => _showMoreActions(context, ref, resolvedEvent),
                  ),
                ],
              ),
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Circle button for top bar trailing ──
  Widget _buildCircleButton(
    IconData icon, {
    VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return GlassIconButton(
      icon: icon,
      iconSize: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      iconColor: isPrimary ? AppColors.primary : AppColors.onSurface,
      onPressed: onTap,
    );
  }

  void _showMoreActions(BuildContext context, WidgetRef ref, EventModel event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => OrganizerEventMoreActionsSheet(
        event: event,
        onManage: onManage,
        onCheckIn: onCheckIn,
        onNotify: onNotify,
        onShare: onShare,
        onRefresh: () => _refreshEventDetailData(ref),
      ),
    );
  }

  void _openOrganizerTeam(BuildContext context, String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => OrganizerTeamView(
          eventId: eventId,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _invalidateEventDetailData(WidgetRef ref) {
    ref.invalidate(organizerEventDetailProvider(eventId));
    ref.invalidate(organizerEventQuestionsProvider(eventId));
  }

  Future<void> _refreshEventDetailData(WidgetRef ref) {
    ref.invalidate(organizerEventQuestionsProvider(eventId));
    return ref
        .refresh(organizerEventDetailProvider(eventId).future)
        .then<void>((_) {});
  }

  Future<void> _activateDraftEvent(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .activateDraftEvent(eventId: eventId);
    if (!context.mounted) return;

    if (ok) {
      showAppSnackBar(context, 'Đã chuyển sự kiện sang trạng thái đang mở.');
      return;
    }

    showAppSnackBar(context, 'Không kích hoạt được sự kiện. Vui lòng thử lại.');
  }
}
