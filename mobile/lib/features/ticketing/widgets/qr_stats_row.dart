// File: lib/features/ticketing/widgets/qr_stats_row.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Translucent pill-shaped stats row showing [checkedIn] and [remaining] counts.
class QrStatsRow extends StatelessWidget {
  final int checkedIn;
  final int remaining;

  const QrStatsRow({
    super.key,
    required this.checkedIn,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: 'ĐÃ CHECK-IN', value: checkedIn),
          Container(
            height: 42,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _StatColumn(label: 'CÒN LẠI', value: remaining),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: AppTextStyles.statNumber.copyWith(
            color: AppColors.primary,
            fontSize: 28,
          ),
        ),
      ],
    );
  }
}
