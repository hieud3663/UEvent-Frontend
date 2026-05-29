// File: lib/widgets/primary_button.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Primary full-width CTA button with optional icon.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final borderRadius = BorderRadius.circular(AppConstants.radiusFull);

    final child = SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary.withValues(alpha: 0.65);
            }
            return AppColors.primary;
          }),
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.onPrimaryDark,
          ),
          overlayColor: WidgetStatePropertyAll(
            AppColors.onPrimaryDark.withValues(alpha: 0.08),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.onPrimaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(label, style: AppTextStyles.buttonLarge),
            if (icon != null && !isLoading) ...[
              const SizedBox(width: 12),
              Icon(icon, size: 20, color: AppColors.onPrimaryDark),
            ],
          ],
        ),
      ),
    );

    return child;
  }
}

/// Secondary outlined/ghost button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isFullWidth = true,
    this.foregroundColor,
    this.borderColor,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? AppColors.onSurface;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: WidgetStatePropertyAll(
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          backgroundColor: WidgetStatePropertyAll(
            backgroundColor ?? Colors.white.withValues(alpha: 0.7),
          ),
          foregroundColor: WidgetStatePropertyAll(effectiveForegroundColor),
          overlayColor: WidgetStatePropertyAll(
            effectiveForegroundColor.withValues(alpha: 0.06),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: borderColor ?? Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: effectiveForegroundColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: effectiveForegroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
