// File: lib/widgets/glass_top_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';
import '../apps/app_text_styles.dart';

/// Floating glassmorphic top navigation bar (iOS 26 style).
/// Used across all screens with flexible leading/trailing widgets.
class GlassTopBar extends StatelessWidget {
  final String title;
  final Widget? leadingWidget;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;
  final TextStyle? titleStyle;

  const GlassTopBar({
    super.key,
    required this.title,
    this.leadingWidget,
    this.leadingIcon,
    this.trailingIcon,
    this.onLeadingTap,
    this.onTrailingTap,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppConstants.glassNavBlur,
              sigmaY: AppConstants.glassNavBlur,
            ),
            child: Container(
              height: AppConstants.topBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowNav,
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Leading
                  if (leadingWidget != null)
                    leadingWidget!
                  else if (leadingIcon != null)
                    _buildIconButton(leadingIcon!, onLeadingTap)
                  else
                    const SizedBox(width: 40),

                  // Title
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: titleStyle ?? AppTextStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Trailing
                  if (trailingIcon != null)
                    _buildIconButton(trailingIcon!, onTrailingTap)
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }
}
