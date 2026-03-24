// File: lib/widgets/empty_state_view.dart

import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_text_styles.dart';

/// Empty state view with animated illustration, title, description, and action buttons.
/// Used in Empty Search screen.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final IconData? secondaryIcon;
  final String title;
  final String description;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    this.secondaryIcon,
    required this.title,
    required this.description,
    this.primaryAction,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration
        _buildIllustration(),
        const SizedBox(height: 32),

        // Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.navInactive,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Actions
        if (primaryAction != null || secondaryAction != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                if (primaryAction != null) primaryAction!,
                if (secondaryAction != null) ...[
                  const SizedBox(height: 12),
                  secondaryAction!,
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 256,
      height: 256,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated glow circle
          Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          // Main icon
          Icon(
            icon,
            size: 96,
            color: AppColors.primary.withValues(alpha: 0.8),
          ),
          // Secondary icon card
          if (secondaryIcon != null)
            Positioned(
              bottom: 40,
              right: 40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  secondaryIcon,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          // Floating glow dots
          Positioned(
            top: 0,
            left: 16,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 16,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
