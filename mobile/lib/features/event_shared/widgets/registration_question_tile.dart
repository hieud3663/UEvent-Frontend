// File: lib/features/event_shared/widgets/registration_question_tile.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class RegistrationQuestionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String typeAndRequirement;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  const RegistrationQuestionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.typeAndRequirement,
    this.onView,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Circular Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.secondary, size: 24),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        typeAndRequirement.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navInactive,
                          letterSpacing: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                color: AppColors.navInactive,
                iconSize: 20,
                splashRadius: 24,
                onPressed: onView,
                hoverColor: Colors.white.withValues(alpha: 0.4),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                iconSize: 20,
                splashRadius: 24,
                onPressed: onDelete,
                hoverColor: AppColors.errorContainer.withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
