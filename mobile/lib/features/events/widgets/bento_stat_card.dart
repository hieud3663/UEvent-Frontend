// File: lib/features/events/widgets/bento_stat_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class BentoStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String metric;
  final String? secondaryMetric;
  final String? percentageStr;
  final double? progressPercentage;
  final bool isHighlightIcon;

  const BentoStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.metric,
    this.secondaryMetric,
    this.percentageStr,
    this.progressPercentage,
    this.isHighlightIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHighlightIcon ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isHighlightIcon ? AppColors.onPrimaryDark : AppColors.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Values Block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.navInactive,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    metric,
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 30,
                    ),
                  ),
                  if (percentageStr != null) ...[
                    Text(
                      percentageStr!,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navInactive.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Bottom Widget (Progress Bar XOR Secondary Metric tag)
          if (progressPercentage != null)
            _buildProgressBar()
          else if (secondaryMetric != null)
            _buildTrendingTag(),
          
          // Empty state spacing if neither provided
          if (progressPercentage == null && secondaryMetric == null)
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          Container(
            width: progressPercentage! * 100, // Assuming 100 wide logically inside flex, but we can't use width hardcoded cleanly if responsive.
            // Better: use FractionallySizedBox
          ),
          FractionallySizedBox(
            widthFactor: progressPercentage,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, size: 12, color: Color(0xFF059669)),
          const SizedBox(width: 4),
          Text(
            secondaryMetric!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}
