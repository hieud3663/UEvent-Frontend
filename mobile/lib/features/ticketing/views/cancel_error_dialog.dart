// File: lib/features/ticketing/views/cancel_error_dialog.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Dialog shown when a user attempts to cancel a registration too late.
class CancelErrorDialog extends StatelessWidget {
  const CancelErrorDialog({super.key});

  /// Shows the error dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const CancelErrorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Cannot Cancel Registration',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Body
            Text(
              'Registrations can only be cancelled at least 24 hours before the event starts. Please contact the organizers for assistance.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // OK button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowPrimary,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'OK, Got It',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.onPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
