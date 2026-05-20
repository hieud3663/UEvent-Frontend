import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
import 'package:frontend/features/events/widgets/bento_stat_card.dart';
import 'package:frontend/features/events/widgets/event_card.dart';

class ManageEventsView extends ConsumerWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onCreateEventTap;
  final ValueChanged<EventModel>? onEventTap;
  final ValueChanged<EventModel>? onManageEventTap;

  const ManageEventsView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onCreateEventTap,
    this.onEventTap,
    this.onManageEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(organizerEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: PrimaryButton(
                    label: 'Tạo sự kiện',
                    icon: Icons.add,
                    onPressed: onCreateEventTap,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ...eventsAsync.when(
                data: (events) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                      ),
                      child: _SummaryGrid(events: events),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                      ),
                      child: SectionHeader(
                        title: 'Event đang quản lý',
                        actionText: '${events.length} EVENT',
                        onActionTap: () {},
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  AppSuccessSliver(
                    isEmpty: events.isEmpty,
                    emptyIcon: Icons.event_available_outlined,
                    emptyTitle: 'Chưa có event quản lý',
                    emptyDescription:
                        'Các event bạn tạo hoặc được phân quyền quản lý sẽ xuất hiện tại đây.',
                    emptyFillRemaining: true,
                    contentSlivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.pagePaddingH,
                              vertical: 8,
                            ),
                            child: EventCard(
                              event: event,
                              formattedDate: DateFormat(
                                'EEE, d MMM',
                              ).format(event.startDate),
                              trailing: _ManageBadge(
                                status: event.status,
                                onTap: onManageEventTap != null
                                    ? () => onManageEventTap!(event)
                                    : null,
                              ),
                              onTap: onEventTap != null
                                  ? () => onEventTap!(event)
                                  : null,
                            ),
                          );
                        }, childCount: events.length),
                      ),
                    ],
                  ),
                ],
                loading: () => const [AppLoadingSliver()],
                error: (error, stackTrace) => [
                  AppErrorSliver(
                    title: 'Không tải được event',
                    description: 'Vui lòng kiểm tra mạng và thử lại.',
                    onRetry: () => ref.refresh(organizerEventsProvider),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(title: 'Quản lý event'),
          ),
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: GlassBottomNavBar.defaultItems,
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final List<EventModel> events;

  const _SummaryGrid({required this.events});

  @override
  Widget build(BuildContext context) {
    final activeCount = events
        .where((event) => event.status == EventStatus.active)
        .length;
    final totalCapacity = events.fold<int>(
      0,
      (total, event) => total + (event.guestCount ?? 0),
    );

    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: BentoStatCard(
              icon: Icons.event_available,
              title: 'Đang chạy',
              metric: activeCount.toString(),
              secondaryMetric: '${events.length} TOTAL',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: BentoStatCard(
              icon: Icons.groups_2_outlined,
              title: 'Sức chứa',
              metric: NumberFormat.compact().format(totalCapacity),
              secondaryMetric: 'MAX CAPACITY',
              isHighlightIcon: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _ManageBadge extends StatelessWidget {
  final EventStatus status;
  final VoidCallback? onTap;

  const _ManageBadge({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.tune,
      onPressed: onTap,
      backgroundColor: _statusColor.withValues(alpha: 0.12),
      iconColor: _statusColor,
      size: 56,
    );
  }

  Color get _statusColor {
    return switch (status) {
      EventStatus.active => AppColors.primary,
      EventStatus.draft => AppColors.primaryDark,
      EventStatus.finished => AppColors.success,
      EventStatus.cancelled => AppColors.error,
    };
  }
}
