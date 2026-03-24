// File: lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';

/// A notification tile matching the Stitch Notifications screen design.
/// Shows icon, title, timestamp, description, and optional action button.
class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String timestamp;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;
  final double opacity;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.timestamp,
    required this.description,
    this.actionLabel,
    this.onActionTap,
    this.onTap,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timestamp.toUpperCase(),
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium,
                    ),

                    // Action button
                    if (actionLabel != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onActionTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 14,
                                color: AppColors.onPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                actionLabel!,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
