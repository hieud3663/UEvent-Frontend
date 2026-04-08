// File: lib/apps/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Centralized typography tokens extracted from UEvents Stitch design.
/// All screens use Inter font family exclusively.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  // ── Display ──
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 52,
    letterSpacing: -1.5,
    color: AppColors.onSurface,
  );

  // ── Headline ──
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    letterSpacing: -0.3,
    color: AppColors.onSurface,
  );

  // ── Title ──
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 20,
    letterSpacing: -0.3,
    color: AppColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 17,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    color: AppColors.onSurface,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.onSurfaceVariant,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );

  // ── Label ──
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.primary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 0.5,
    color: AppColors.secondary,
  );

  // ── Special ──
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 0.5,
  );

  static const TextStyle dateTag = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  static const TextStyle statNumber = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.primary,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 17,
    color: AppColors.onPrimaryDark,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 10,
    letterSpacing: 1.0,
    color: AppColors.navInactive,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: AppColors.onSurface,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: AppColors.outline,
  );
}
