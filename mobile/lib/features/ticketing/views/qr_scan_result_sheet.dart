// File: lib/features/ticketing/views/qr_scan_result_sheet.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/primary_button.dart';

/// Modal bottom sheet that shows either a scan SUCCESS or ERROR result.
///
/// Usage:
/// ```dart
/// QrScanResultSheet.show(
///   context,
///   isSuccess: true,
///   attendeeName: 'Nguyễn Văn A',
///   attendeeId: '21520000',
///   onScanNext: () {},
///   onTryAgain: () {},
///   onCancel: () {},
/// );
/// ```
class QrScanResultSheet extends StatelessWidget {
  final bool isSuccess;
  final String? title;
  final String? description;
  final String? attendeeName;
  final String? attendeeId;
  final VoidCallback onScanNext;
  final VoidCallback onTryAgain;
  final VoidCallback onCancel;

  const QrScanResultSheet({
    super.key,
    required this.isSuccess,
    this.title,
    this.description,
    this.attendeeName,
    this.attendeeId,
    required this.onScanNext,
    required this.onTryAgain,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isSuccess,
    String? title,
    String? description,
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
        title: title,
        description: description,
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
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title ?? 'Check-in thành công',
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6366F1),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Name & ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendeeName ?? 'Nguyễn Văn A',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: const Text(
                  'HỢP LỆ',
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
        PrimaryButton(label: 'Quét vé tiếp theo', onPressed: onScanNext),
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
          title ?? 'Vé không hợp lệ',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          description ??
              'Vé này đã được sử dụng hoặc không hợp lệ cho sự kiện này. '
                  'Vui lòng liên hệ ban tổ chức để được hỗ trợ.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Try Again button
        PrimaryButton(label: 'Thử lại', onPressed: onTryAgain),
        const SizedBox(height: 8),

        SecondaryButton(label: 'Hủy', onPressed: onCancel),
        const SizedBox(height: 4),
      ],
    );
  }
}
