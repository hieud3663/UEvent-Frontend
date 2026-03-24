// File: lib/widgets/glass_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../apps/app_colors.dart';
import '../apps/app_constants.dart';

/// A reusable glassmorphism container matching iOS 26 frosted glass style.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppConstants.radiusCard,
    this.padding,
    this.blur = AppConstants.glassBlur,
    this.opacity = AppConstants.glassOpacity,
    this.borderOpacity = AppConstants.glassBorderOpacity,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 0.5,
            ),
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: AppColors.shadowSubtle,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
