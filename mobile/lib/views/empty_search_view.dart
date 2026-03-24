// File: lib/views/empty_search_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';

import '../apps/app_text_styles.dart';
import '../widgets/glass_top_bar.dart';
import '../widgets/glass_bottom_nav_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/primary_button.dart';

class EmptySearchView extends StatelessWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback? onBack;
  final VoidCallback? onGoHome;

  const EmptySearchView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onBack,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              GlassTopBar(
                title: 'Tìm kiếm',
                leadingIcon: Icons.close,
                trailingIcon: Icons.more_vert,
                onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
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
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: GlassBottomNavBar.defaultItems,
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
        boxShadow: [
          BoxShadow(color: AppColors.shadowNav, blurRadius: 32),
        ],
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
