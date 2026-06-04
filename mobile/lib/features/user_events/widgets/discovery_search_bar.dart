import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class DiscoverySearchBar extends StatelessWidget {
  const DiscoverySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
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
