import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/organizer_events/models/organizer_notification_template.dart';

class NotificationTemplateCard extends StatelessWidget {
  final OrganizerNotificationTemplate template;
  final String eventTitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const NotificationTemplateCard({
    super.key,
    required this.template,
    required this.eventTitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(template.icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            template.badge,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle, color: color, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.resolveTitle(eventTitle),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      template.resolveMessage(eventTitle),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
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
