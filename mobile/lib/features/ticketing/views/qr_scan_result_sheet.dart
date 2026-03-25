// File: lib/features/ticketing/views/qr_scan_result_sheet.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Modal bottom sheet that shows either a scan SUCCESS or ERROR result.
///
/// Usage:
/// ```dart
/// QrScanResultSheet.show(
///   context,
///   isSuccess: true,
///   attendeeName: 'Nguyen Van A',
///   attendeeId: '21520000',
///   onScanNext: () {},
///   onTryAgain: () {},
///   onCancel: () {},
/// );
/// ```
class QrScanResultSheet extends StatelessWidget {
  final bool isSuccess;
  final String? attendeeName;
  final String? attendeeId;
  final VoidCallback onScanNext;
  final VoidCallback onTryAgain;
  final VoidCallback onCancel;

  const QrScanResultSheet({
    super.key,
    required this.isSuccess,
    this.attendeeName,
    this.attendeeId,
    required this.onScanNext,
    required this.onTryAgain,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isSuccess,
    String? attendeeName,
    String? attendeeId,
    required VoidCallback onScanNext,
    required VoidCallback onTryAgain,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => QrScanResultSheet(
        isSuccess: isSuccess,
        attendeeName: attendeeName,
        attendeeId: attendeeId,
        onScanNext: onScanNext,
        onTryAgain: onTryAgain,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: const BoxDecoration(
        color: Color(0xFFD1D1D6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: isSuccess ? _buildSuccess() : _buildError(),
        ),
      ),
    );
  }

  // ── Success ──────────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Golden icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded,
              color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Check-in Successful',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Attendee card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 26),
              ),
              const SizedBox(width: 12),

              // Name & ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendeeName ?? 'Nguyen Van A',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MSSV: ${attendeeId ?? '21520000'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // VALID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: const Text(
                  'VALID',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Scan Next button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              elevation: 0,
            ),
            onPressed: onScanNext,
            child: const Text(
              'Scan Next',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Red × icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: AppColors.error, size: 32),
        ),
        const SizedBox(height: 20),

        // Title
        Text(
          'Invalid Ticket',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'This ticket has already been used or is not valid for this event. '
          'Please contact the event organizer for assistance.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Try Again button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              elevation: 0,
            ),
            onPressed: onTryAgain,
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Cancel text button
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
