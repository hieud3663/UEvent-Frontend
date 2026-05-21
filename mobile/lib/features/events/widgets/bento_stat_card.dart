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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 160 || constraints.maxWidth < 160;
        final padding = compact ? 14.0 : 20.0;
        final iconSize = compact ? 34.0 : 40.0;
        final iconGlyphSize = compact ? 18.0 : 20.0;
        final valueGap = compact ? 8.0 : 16.0;
        final bottomGap = compact ? 6.0 : 8.0;
        final metricFontSize = compact ? 24.0 : 30.0;

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
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: isHighlightIcon
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isHighlightIcon
                      ? AppColors.onPrimaryDark
                      : AppColors.primary,
                  size: iconGlyphSize,
                ),
              ),
              SizedBox(height: valueGap),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        Flexible(
                          child: Text(
                            metric,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: metricFontSize,
                            ),
                          ),
                        ),
                        if (percentageStr != null)
                          Text(
                            percentageStr!,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navInactive.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: bottomGap),
              if (progressPercentage != null)
                _buildProgressBar()
              else if (secondaryMetric != null)
                _buildTrendingTag()
              else
                SizedBox(height: compact ? 8 : 16),
            ],
          ),
        );
      },
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
      child: FractionallySizedBox(
        widthFactor: progressPercentage,
        alignment: Alignment.centerLeft,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTag() {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
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
          Flexible(
            child: Text(
              secondaryMetric!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
