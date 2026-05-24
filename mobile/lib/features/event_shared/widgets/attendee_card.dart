// File: lib/features/event_shared/widgets/attendee_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

enum AttendeeStatus { checkedIn, registered, waitlisted, pending, cancelled }

class AttendeeCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String studentId;
  final AttendeeStatus status;
  final String? timestamp;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AttendeeCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.studentId,
    required this.status,
    this.timestamp,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Styling based on status
    final Color badgeColor = switch (status) {
      AttendeeStatus.checkedIn ||
      AttendeeStatus.registered => AppColors.success,
      AttendeeStatus.waitlisted || AttendeeStatus.pending => AppColors.primary,
      AttendeeStatus.cancelled => AppColors.error,
    };
    final Color tagBgColor = badgeColor.withValues(alpha: 0.15);
    final Color tagTextColor = badgeColor;
    final String statusLabel = switch (status) {
      AttendeeStatus.checkedIn => 'ĐÃ CHECK-IN',
      AttendeeStatus.registered => 'ĐÃ ĐĂNG KÝ',
      AttendeeStatus.waitlisted => 'DANH SÁCH CHỜ',
      AttendeeStatus.pending => 'ĐANG CHỜ',
      AttendeeStatus.cancelled => 'ĐÃ HỦY',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(
            32,
          ), // large rounded corners like design
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Avatar with indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Name & ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $studentId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.navInactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            if (trailing != null)
              trailing!
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: tagTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timestamp ?? '—',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.navInactive,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
