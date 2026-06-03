// File: lib/features/organizer_events/views/event_detail_organizer_view.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/team_member_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/event_shared/models/event_question_model.dart';
import 'package:frontend/features/event_shared/widgets/team_member_tile.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_question_thread.dart';

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
                'Bạn không có quyền organizer hoặc sự kiện không tồn tại.',
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
                    child: _buildHeroImage(resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Category Badge + Title + Meta ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: _buildEventInfo(resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Organizer Action Buttons (Notify / Manage) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: _buildActionButtons(),
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
                    child: _buildStatsSection(resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Event Description ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: _buildDescriptionSection(resolvedEvent),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: _OrganizerEngagementSection(eventId: eventId),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── BTC Team ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: _buildTeamSection(resolvedEvent),
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
                letterSpacing: -0.3,
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
                  _buildCircleButton(Icons.more_vert, onTap: () {}),
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

  // ── Hero Image with Live badge ──
  Widget _buildHeroImage(EventModel event) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: event.imageUrl,
            fit: BoxFit.cover,
            memCacheWidth: 1200,
            maxWidthDiskCache: 1800,
            errorWidget: (context, url, error) =>
                Container(color: AppColors.surfaceVariant),
          ),
          // "Live Now" badge
          Positioned(
            top: 16,
            right: 16,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: 9999,
              child: Text(
                event.status.name.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Event Info: category badge, title, date, location ──
  Widget _buildEventInfo(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            event.category?.toUpperCase() ?? 'EVENT',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          event.title,
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        // Date row
        _buildInfoRow(
          Icons.calendar_month,
          '${DateFormat('MMM d, yyyy').format(event.startDate.toLocal())} • ${_formatTimeRange(event)}',
        ),
        const SizedBox(height: 12),
        // Location row
        _buildInfoRow(
          Icons.location_on,
          event.location.isNotEmpty ? event.location : 'Chưa có địa điểm',
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.navInactive,
            ),
          ),
        ),
      ],
    );
  }

  // ── Action Buttons: Notify / Manage ──
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionChip(Icons.send, 'Notify', onNotify)),
        const SizedBox(width: 12),
        Expanded(child: _buildActionChip(Icons.settings, 'Manage', onManage)),
      ],
    );
  }

  Widget _buildActionChip(IconData icon, String label, VoidCallback? onTap) {
    return PrimaryButton(
      label: label,
      icon: icon,
      isFullWidth: true,
      onPressed: onTap,
    );
  }

  // ── Stats: Tickets Sold + Pending Approvals ──
  Widget _buildStatsSection(EventModel event) {
    return Column(
      children: [
        // Tickets Sold
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKETS SOLD',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 2.0,
                  color: AppColors.navInactive,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.guestCount ?? 0}',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 30),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF059669),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+12%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pending Approvals
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING APPROVALS',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 2.0,
                        color: AppColors.navInactive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${event.registrationFields.length} Registration Fields',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ],
                ),
              ),
              // Stacked avatars
              SizedBox(
                width: 88,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildSmallAvatar(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB-d1vmiJ14n16NNg466wUFGDC6CFrZckYrbzXeKZrijCMo9M58HKs3kWjs-CILqQMfdQkw2GY3kHH_taQiBf8gaEaL6PzKTSK9P5q7_Iac16Yoq1-hy0lzJKk0JXyaOg6jVBFiduww_6nNZgJpynwzaQJ6ohs9JEffcWOqanESgrWLbzQCJpkrrG9iQeCVfoSFOss5kvI595oahmbk9MdWONZ7JNAF8TTwcZNMXXWWCJVLaWkDOFi-ZWAy8rXYGp45Ofjw_mtHbBA',
                      ),
                    ),
                    Positioned(
                      left: 26,
                      child: _buildSmallAvatar(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDX2Tn5stZ_okdusxrUK7RR5Nr5T23JLRYSCqcd561ER9l92kk8x5yim9o1fHSv_RRFMoFUIVTZG9LZj9IvWd4r2G6dYkWxt4dw1NNXlcFgcKHL0YAfqTw6wsmpOTR8mE0lD_Si_aR_tLBfZcrNpAhJtsA_jm28_degoIq7x8pw57DA5UALVCMwdpDB0R7x4CyFI9M2QMkjSn2b9Lzw1m8PtI9e6EEtdTs8C9E1u0OQ0-7mi1ApnsaO7ygRD3ggr4jtuEZSs8LzCJk',
                      ),
                    ),
                    Positioned(
                      left: 52,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${event.registrationFields.length}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallAvatar(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: 96,
          maxWidthDiskCache: 192,
          errorWidget: (context, url, error) =>
              Container(color: AppColors.surfaceVariant),
        ),
      ),
    );
  }

  // ── Description ──
  Widget _buildDescriptionSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mô tả sự kiện', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          event.description ?? 'Chưa có mô tả sự kiện.',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.onSurfaceVariant,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Read more',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16, color: AppColors.primary),
          ],
        ),
      ],
    );
  }

  // ── BTC Team Section ──
  Widget _buildTeamSection(EventModel event) {
    final teamMembers = _teamMembersFromEvent(event);

    return Column(
      children: [
        SectionHeader(
          title: 'Đội ngũ BTC',
          titleStyle: AppTextStyles.headlineMedium,
          actionText: 'Xem tất cả',
          onActionTap: () {},
        ),
        const SizedBox(height: 12),
        ...List.generate(
          teamMembers.length,
          (i) => Padding(
            padding: EdgeInsets.only(
              bottom: i < teamMembers.length - 1 ? 12 : 0,
            ),
            child: TeamMemberTile(member: teamMembers[i]),
          ),
        ),
      ],
    );
  }

  List<TeamMemberModel> _teamMembersFromEvent(EventModel event) {
    return event.organizers
        .map(
          (organizer) => TeamMemberModel(
            id: organizer.id,
            name: organizer.user.displayName,
            role: organizer.organizerRole,
            avatarUrl: organizer.user.avatarUrl,
          ),
        )
        .toList();
  }

  String _formatTimeRange(EventModel event) {
    if (event.timeRange?.isNotEmpty == true) return event.timeRange!;

    final start = DateFormat('HH:mm').format(event.startDate.toLocal());
    final end = event.endDate == null
        ? null
        : DateFormat('HH:mm').format(event.endDate!.toLocal());
    return end == null ? start : '$start - $end';
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
      showAppSnackBar(context, 'Đã chuyển sự kiện sang Active.');
      return;
    }

    showAppSnackBar(context, 'Không kích hoạt được sự kiện. Vui lòng thử lại.');
  }
}

class _OrganizerEngagementSection extends ConsumerWidget {
  final String eventId;

  const _OrganizerEngagementSection({required this.eventId});

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
            title: 'Không tải được bình luận',
            description: 'Vui lòng thử lại sau.',
            padding: EdgeInsets.zero,
            onRetry: () =>
                ref.invalidate(organizerEventQuestionsProvider(eventId)),
          ),
          data: (questions) =>
              _QuestionListCard(eventId: eventId, questions: questions),
        ),
      ],
    );
  }
}

class _QuestionListCard extends StatelessWidget {
  final String eventId;
  final List<EventQuestionModel> questions;

  const _QuestionListCard({required this.eventId, required this.questions});

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
