// File: lib/widgets/glass_bottom_nav_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// iOS 26 style glassmorphic floating bottom navigation bar.
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemModel> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static List<NavItemModel> get defaultItems => const [
    NavItemModel(
      label: 'HOME',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    NavItemModel(
      label: 'DISCOVER',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    NavItemModel(
      label: 'TICKETS',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number,
    ),
    NavItemModel(
      label: 'SETTINGS',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final content = Container(
      height: AppConstants.bottomNavHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppConstants.radiusNav),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNav,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;
          return _NavBarItem(
            item: item,
            isActive: isActive,
            onTap: () => onTap(index),
          );
        }),
      ),
    );

    return Positioned(
      left: 24,
      right: 24,
      bottom: AppConstants.bottomNavOffset,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusNav),
        child: isAndroid
            ? content
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppConstants.glassNavBlur,
                  sigmaY: AppConstants.glassNavBlur,
                ),
                child: content,
              ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final NavItemModel item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: 34,
          child: AnimatedScale(
            scale: isActive ? 1.1 : 1.0,
            duration: AppConstants.animFast,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 26,
                  color: isActive ? AppColors.navActive : AppColors.navInactive,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: AppTextStyles.navLabel.copyWith(
                    color: isActive
                        ? AppColors.navActive
                        : AppColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
