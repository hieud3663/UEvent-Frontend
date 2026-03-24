// File: lib/views/discovery_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';
import '../models/event_model.dart';
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

  const DiscoveryView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onSearchEmpty,
  });

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Music',
    'Academic',
    'Sports',
    'Upcoming',
    'Tech',
  ];

  static final List<EventModel> _events = [
    EventModel(
      id: '1',
      title: 'Summer Beats Festival',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCeQBq3SB4o6ijps-gBLfANONvG6DZo-EyEXFXHUHBeewAffv2GsGbC5WVz0GcR3n2_I1fpudHo-Q474dzbpPOa9HmbAYvciXGnGjyGy6wZpfIW6tn68T2pWi531NLl1k_lLniE9jXAcdVY46Yu1FBFNL0yP-JVGY3qdVF_fwo0nV8QO_04aoTz87iHApTIRBd6APoJsnNOq3D6Ub6mNFzD8uTS2PxAXr1BdF1_9oxWV84QIEnU-XGEkC2R6KmwzDeS2370Ddbr6J8',
      location: 'Main Campus Plaza, CA',
      startDate: DateTime(2024, 8, 24),
      timeRange: '08:00 PM - 02:00 AM',
      category: 'Music',
    ),
    EventModel(
      id: '2',
      title: 'Future of AI Summit',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAEe8TiBatwY617qcuKh7CbBA2RCdpsNDZV6tXtdoEBV2EtUzt_iJzl_n8BLOnEldIK96mhNyWv3ljOt1DCrOZwg35QDPlfTWQ1SJs9Nb6oJFT-HQ3Sp8WTwGnDhCUzKVCxmu4QYufHq3mj1dChw0SWQhDfZqemiu9bsS6J55OnNtM4Dus6-epR6U6Izbuaj5v1pBkljSqSJBOreAVKjqRNDuPEji5bUJ7zatWmBVhNBByt4XfpXJDqXZDYJBeaweBptbmtd9k5_dc',
      location: 'Grand Innovation Hall',
      startDate: DateTime(2024, 9, 12),
      timeRange: '10:00 AM - 04:00 PM',
      category: 'Tech',
    ),
    EventModel(
      id: '3',
      title: 'Championship Qualifiers',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDttCruWuFR4EfJM10dJpyryKeWwKmu847sRG5y07zX_HCWUP8pRW0vMm3OXLJ7M-xPmwGwo8mKm9vZkjDEOnrwoymhr6bTe61IWNw8CQgmHCfRM1DU8NRZHCKvWz20hc5FIQVh10mCUagjAiq4wWnAc6IQ6bdCsHqABwGSrF9Mujm1jCYALnnZkwi2ZcXl0QVLFieG_Pjd2Mw_W-ShWw2g5bxq1479eNVBMuRrhPe_hbonHlhnOJN3aNF-iNA3j0XAnAkQMtLVqP0',
      location: 'University Stadium',
      startDate: DateTime(2024, 9, 5),
      timeRange: '02:00 PM - 05:30 PM',
      category: 'Sports',
    ),
  ];

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
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return CategoryFilterChip(
                        label: _categories[index],
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
                    final event = _events[index];
                    final dateBadges = ['AUG 24', 'SEP 12', 'SEP 05'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.pagePaddingH,
                        vertical: 12,
                      ),
                      child: EventCardVertical(
                        event: event,
                        dateBadge: dateBadges[index],
                      ),
                    );
                  },
                  childCount: _events.length,
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
