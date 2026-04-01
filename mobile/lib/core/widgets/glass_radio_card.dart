// File: lib/core/widgets/glass_radio_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';

class GlassRadioCard<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final IconData icon;
  final String title;
  final String subtitle;

  const GlassRadioCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 16,
        blur: isSelected ? 40 : 12,
        backgroundColor: isSelected 
            ? Colors.white.withValues(alpha: 0.9) 
            : Colors.white.withValues(alpha: 0.7),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : Colors.white.withValues(alpha: 0.4),
          width: isSelected ? 2.0 : 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected 
                    ? AppColors.onPrimaryDark 
                    : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                letterSpacing: -0.2, // Tighter tracking per design
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
