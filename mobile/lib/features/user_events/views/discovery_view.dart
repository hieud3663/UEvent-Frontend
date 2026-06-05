// File: lib/features/user_events/views/discovery_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_category_model.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/features/event_shared/widgets/event_card_vertical.dart';
import 'package:frontend/features/event_shared/widgets/category_filter_chip.dart';
import 'package:frontend/features/notifications/providers/notification_data_providers.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/features/user_events/widgets/discovery_notification_button.dart';
import 'package:frontend/features/user_events/widgets/discovery_paging_footer.dart';
import 'package:frontend/features/user_events/widgets/discovery_profile_avatar.dart';
import 'package:frontend/features/user_events/widgets/discovery_search_bar.dart';

class DiscoveryView extends ConsumerStatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchEmpty;
  final ValueChanged<EventModel>? onEventTap;
  final String? profileAvatarUrl;
  final String? profileAvatarCacheKey;
  final String? profileName;
  final List<NavItemModel> navItems;

  const DiscoveryView({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onSearchEmpty,
    this.onEventTap,
    this.profileAvatarUrl,
    this.profileAvatarCacheKey,
    this.profileName,
    this.navItems = GlassBottomNavBar.defaultItems,
  });

  @override
  ConsumerState<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends ConsumerState<DiscoveryView> {
  final _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  String? _selectedCategoryQuery;

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
    final categoriesAsync = ref.watch(userEventCategoriesProvider);
    final loadedCategories = categoriesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => null,
    );
    final categories = [EventCategoryModel.all, ...?loadedCategories];
    final safeSelectedIndex = _selectedCategoryIndex >= categories.length
        ? 0
        : _selectedCategoryIndex;
    final categoryQuery = _selectedCategoryQuery;
    final eventsAsync = ref.watch(
      userDiscoveryEventsPagerProvider(categoryQuery),
    );
    final unreadCount = ref.watch(notificationUnreadCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _refreshDiscovery(categoryQuery),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Spacing for fixed top bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingHLarge,
                      vertical: 16,
                    ),
                    child: const DiscoverySearchBar(),
                  ),
                ),
                // Filter chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                      ),
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return CategoryFilterChip(
                          label: categories[index].name,
                          isSelected: index == safeSelectedIndex,
                          onTap: () {
                            final selectedCategory = categories[index];
                            final nextQuery =
                                selectedCategory == EventCategoryModel.all
                                ? null
                                : selectedCategory.queryValue;
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedCategoryQuery = nextQuery;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: SectionHeader(
                      title: 'Sự kiện nổi bật',
                      titleStyle: AppTextStyles.headlineLarge,
                      onActionTap: () {},
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Event cards
                ...eventsAsync.when(
                  data: (pagedState) {
                    final events = pagedState.events;
                    return [
                      AppSuccessSliver(
                        isEmpty: events.isEmpty,
                        emptyIcon: Icons.explore_off,
                        emptyTitle: 'Không có sự kiện',
                        emptyDescription:
                            'Không tìm thấy sự kiện phù hợp hiện tại.',
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
                                  vertical: 12,
                                ),
                                child: EventCardVertical(
                                  event: event,
                                  dateBadge: DateFormat(
                                    'd MMM',
                                    'vi',
                                  ).format(event.startDate.toLocal()),
                                  onTap: widget.onEventTap != null
                                      ? () => widget.onEventTap!(event)
                                      : null,
                                ),
                              );
                            }, childCount: events.length),
                          ),
                          SliverToBoxAdapter(
                            child: DiscoveryPagingFooter(
                              hasMore: pagedState.hasMore,
                              isLoadingMore: pagedState.isLoadingMore,
                              hasError: pagedState.loadMoreError != null,
                              onRetry: () => ref
                                  .read(
                                    userDiscoveryEventsPagerProvider(
                                      categoryQuery,
                                    ).notifier,
                                  )
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
                      icon: Icons.wifi_off,
                      title: 'Không tải dữ liệu được',
                      description: 'Vui lòng thử lại sau.',
                      onRetry: () => ref.invalidate(
                        userDiscoveryEventsPagerProvider(categoryQuery),
                      ),
                    ),
                  ],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          // Top Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Trang chủ',
              leadingWidget: GestureDetector(
                onTap: widget.onProfileTap,
                child: DiscoveryProfileAvatar(
                  avatarUrl: widget.profileAvatarUrl,
                  avatarCacheKey: widget.profileAvatarCacheKey,
                  displayName: widget.profileName,
                ),
              ),
              trailingWidget: DiscoveryNotificationButton(
                unreadCount: unreadCount,
                onTap: widget.onNotificationsTap,
              ),
            ),
          ),
          // Bottom Nav
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            onTap: widget.onNavTap,
            items: widget.navItems,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDiscovery(String? categoryQuery) async {
    try {
      await Future.wait([
        ref.refresh(userEventCategoriesProvider.future).then((_) {}),
        ref
            .read(userDiscoveryEventsPagerProvider(categoryQuery).notifier)
            .refreshPage()
            .then((_) {}),
      ]);
    } catch (_) {
      // Providers keep their error state for the existing error UI.
    }
  }

  void _maybeLoadNextPage() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.extentAfter > 700) return;

    ref
        .read(userDiscoveryEventsPagerProvider(_selectedCategoryQuery).notifier)
        .loadNextPage();
  }
}
