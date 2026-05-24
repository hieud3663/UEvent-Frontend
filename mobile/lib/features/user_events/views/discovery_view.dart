// File: lib/features/user_events/views/discovery_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
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
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/text_action_button.dart';

class DiscoveryView extends ConsumerStatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchEmpty;
  final ValueChanged<EventModel>? onEventTap;

  const DiscoveryView({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onSearchEmpty,
    this.onEventTap,
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
                    child: _buildSearchBar(),
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
                      actionText: 'Xem tất cả',
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
                                    'MMM d',
                                  ).format(event.startDate),
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
                child: _buildAvatar(),
              ),
              trailingIcon: Icons.notifications_outlined,
              onTrailingTap: widget.onNotificationsTap,
            ),
          ),
          // Bottom Nav
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            onTap: widget.onNavTap,
            items: GlassBottomNavBar.defaultItems,
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

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ',
          fit: BoxFit.cover,
          memCacheWidth: 96,
          maxWidthDiskCache: 192,
          errorWidget: (context, url, error) =>
              Container(color: AppColors.surfaceVariant),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.navInactive, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sự kiện...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.navInactive,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
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
