// File: lib/features/ticketing/views/cancel_confirmation_sheet.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Bottom sheet that asks the user to confirm cancellation of a registration.
class CancelConfirmationSheet extends StatelessWidget {
  final String eventName;
  final VoidCallback? onConfirm;
  final VoidCallback? onKeep;

  const CancelConfirmationSheet({
    super.key,
    required this.eventName,
    this.onConfirm,
    this.onKeep,
  });

  /// Shows the confirmation bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String eventName,
    VoidCallback? onConfirm,
    VoidCallback? onKeep,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelConfirmationSheet(
        eventName: eventName,
        onConfirm: onConfirm,
        onKeep: onKeep,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
          ),
          const SizedBox(height: 24),

          // Warning icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Hủy đăng ký?',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Body
          Text(
            'Bạn chắc chắn muốn hủy đăng ký $eventName? Hành động này không thể hoàn tác.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Yes, Cancel (destructive)
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Có, hủy đăng ký',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Keep registration
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onKeep ?? () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Giữ đăng ký của tôi',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
