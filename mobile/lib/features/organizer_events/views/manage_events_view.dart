import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/widgets/event_card.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/manage_event_badge.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_list_formatters.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_events_paging_footer.dart';

class ManageEventsView extends ConsumerStatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onCreateEventTap;
  final ValueChanged<EventModel>? onEventTap;
  final ValueChanged<EventModel>? onManageEventTap;
  final List<NavItemModel> navItems;

  const ManageEventsView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onCreateEventTap,
    this.onEventTap,
    this.onManageEventTap,
    this.navItems = GlassBottomNavBar.defaultItems,
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
                            title: 'Sự kiện của tôi',
                            actionText: '${events.length} sự kiện',
                            onActionTap: () {},
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      AppSuccessSliver(
                        isEmpty: events.isEmpty,
                        emptyIcon: Icons.event_available_outlined,
                        emptyTitle: 'Chưa có sự kiện quản lý',
                        emptyDescription:
                            'Các sự kiện bạn tạo hoặc được phân quyền quản lý sẽ xuất hiện tại đây.',
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
                                  formattedDate: formatOrganizerEventListDate(
                                    event.startDate,
                                  ),
                                  trailing: ManageEventBadge(
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
                            child: OrganizerEventsPagingFooter(
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
                      title: 'Không tải được sự kiện',
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
            child: GlassTopBar(title: 'Quản lý sự kiện'),
          ),
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            onTap: widget.onNavTap,
            items: widget.navItems,
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
