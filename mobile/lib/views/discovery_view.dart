// File: lib/views/discovery_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';
import '../models/event_model.dart';
import '../mock/mock_event_data.dart';
import '../widgets/glass_top_bar.dart';
import '../widgets/glass_bottom_nav_bar.dart';
import '../widgets/event_card_vertical.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/section_header.dart';

class DiscoveryView extends StatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchEmpty;
  final ValueChanged<EventModel>? onEventTap;

  const DiscoveryView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onSearchEmpty,
    this.onEventTap,
  });

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // Top bar
              SliverToBoxAdapter(
                child: GlassTopBar(
                  title: 'Discovery',
                  leadingWidget: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: _buildAvatar(),
                  ),
                  trailingIcon: Icons.notifications_outlined,
                  onTrailingTap: widget.onNotificationsTap,
                ),
              ),
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
                    itemCount: MockEventData.discoveryCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return CategoryFilterChip(
                        label: MockEventData.discoveryCategories[index],
                        isSelected: index == _selectedCategoryIndex,
                        onTap: () {
                          setState(() => _selectedCategoryIndex = index);
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
                    title: 'Discover Events',
                    titleStyle: AppTextStyles.headlineLarge,
                    actionText: 'See all',
                    onActionTap: () {},
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // Event cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = MockEventData.discoveryEvents[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                        vertical: 12,
                      ),
                      child: EventCardVertical(
                        event: event,
                        dateBadge: MockEventData.discoveryDateBadges[index],
                        onTap: widget.onEventTap != null
                            ? () => widget.onEventTap!(event)
                            : null,
                      ),
                    );
                  },
                  childCount: MockEventData.discoveryEvents.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
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
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAyErzTlXp9zTUqK8e5HiJWesNTOfm10_r_PwBXepemKvp1azWgTJAsFJJ7snljJsrTQulkOtMR9kLjkqonSvAXShUrveuMti8KGM5D-f6OVJouUop9N2kaqC5W_37NT0ujje2mjYinxeiOmIA1h6bBYsST_0xbefLJ6Fy7tWlS1OL1t5CFyCJZ5_vNtl2jJTv53homf79hhU0pUjNet7E-O1x01Cqh2Rm16YoGnZsETeXS4e1oJI4IkqzfhaISEsjxeBlSTJgL8NQ',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
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
        boxShadow: [
          BoxShadow(color: AppColors.shadowSubtle, blurRadius: 8),
        ],
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
                hintText: 'Search events...',
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
