// File: lib/features/user_events/views/empty_search_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';

import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/empty_state_view.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class EmptySearchView extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onBack;
  final VoidCallback? onGoHome;
  final List<NavItemModel> navItems;

  const EmptySearchView({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavTap,
    this.onBack,
    this.onGoHome,
    this.navItems = GlassBottomNavBar.defaultItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 100),
              // Search bar with value
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBar(),
              ),
              // Empty state
              Expanded(
                child: EmptyStateView(
                  icon: Icons.event_busy,
                  secondaryIcon: Icons.search_off,
                  title: 'Không tìm thấy sự kiện nào',
                  description:
                      'Rất tiếc, chúng tôi không tìm thấy kết quả nào phù hợp với từ khóa của bạn. Thử tìm kiếm với một từ khóa khác nhé!',
                  primaryAction: PrimaryButton(
                    label: 'Thử lại',
                    onPressed: onBack,
                  ),
                  secondaryAction: SecondaryButton(
                    label: 'Quay lại trang chủ',
                    onPressed: onGoHome,
                  ),
                ),
              ),
            ],
          ),
          // Top Bar Fixed
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Tìm kiếm',
              leadingIcon: Icons.close,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: navItems,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [BoxShadow(color: AppColors.shadowNav, blurRadius: 32)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.navInactive, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lễ hội âm nhạc Jazz',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
