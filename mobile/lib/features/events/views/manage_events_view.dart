import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/text_action_button.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
import 'package:frontend/features/events/widgets/event_card.dart';

class ManageEventsView extends ConsumerStatefulWidget {
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
  ConsumerState<ManageEventsView> createState() => _ManageEventsViewState();
}

class _ManageEventsViewState extends ConsumerState<ManageEventsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadNextPage);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadNextPage)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(organizerEventsPagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom:
              AppConstants.bottomNavHeight + AppConstants.bottomNavOffset + 12,
        ),
        child: FloatingActionButton.extended(
          onPressed: widget.onCreateEventTap,
          icon: const Icon(Icons.add),
          label: const Text('Tạo sự kiện'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                ref.read(organizerEventsPagerProvider.notifier).refreshPage(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ...eventsAsync.when(
                  data: (pagedState) {
                    final events = pagedState.events;
                    return [
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
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
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
                                    onTap: widget.onManageEventTap != null
                                        ? () => widget.onManageEventTap!(event)
                                        : null,
                                  ),
                                  onTap: widget.onEventTap != null
                                      ? () => widget.onEventTap!(event)
                                      : null,
                                ),
                              );
                            }, childCount: events.length),
                          ),
                          SliverToBoxAdapter(
                            child: _PagingFooter(
                              hasMore: pagedState.hasMore,
                              isLoadingMore: pagedState.isLoadingMore,
                              hasError: pagedState.loadMoreError != null,
                              onRetry: () => ref
                                  .read(organizerEventsPagerProvider.notifier)
                                  .loadNextPage(),
                            ),
                          ),
                        ],
                      ),
                    ];
                  },
                  loading: () => const [AppLoadingSliver()],
                  error: (error, stackTrace) => [
                    AppErrorSliver(
                      title: 'Không tải được event',
                      description: 'Vui lòng kiểm tra mạng và thử lại.',
                      onRetry: () =>
                          ref.invalidate(organizerEventsPagerProvider),
                    ),
                  ],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(title: 'Quản lý event'),
          ),
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            onTap: widget.onNavTap,
            items: GlassBottomNavBar.defaultItems,
          ),
        ],
      ),
    );
  }

  void _maybeLoadNextPage() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.extentAfter > 600) return;

    ref.read(organizerEventsPagerProvider.notifier).loadNextPage();
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

class _PagingFooter extends StatelessWidget {
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasError;
  final VoidCallback onRetry;

  const _PagingFooter({
    required this.hasMore,
    required this.isLoadingMore,
    required this.hasError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextActionButton(label: 'Thử lại', onPressed: onRetry),
        ),
      );
    }

    if (!hasMore) {
      return const SizedBox(height: 8);
    }

    return const SizedBox(height: 24);
  }
}
