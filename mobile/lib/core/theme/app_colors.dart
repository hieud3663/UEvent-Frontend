// File: lib/apps/app_colors.dart

import 'dart:ui';

/// Centralized color tokens extracted from UEvents Stitch design.
/// iOS 26 Deep Yellow design system.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryContainer = Color(0xFFFFCC00);
  static const Color primaryFixed = Color(0xFFFFEDBC);
  static const Color primaryFixedDim = Color(0xFFFFBA20);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF271900);
  static const Color onPrimaryContainer = Color(0xFF453200);

  // ── Secondary ──
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryContainer = Color(0xFFF1F5F9);
  static const Color secondaryFixed = Color(0xFFE2E8F0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1E293B);

  // ── Tertiary ──
  static const Color tertiary = Color(0xFF101322);
  static const Color tertiaryContainer = Color(0xFF1E293B);

  // ── Success & Error ──
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // ── Background & Surface ──
  static const Color background = Color(0xFFF5F6F8);
  static const Color surface = Color(0xFFFFF8F2);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE8EAF0);
  static const Color surfaceContainerLow = Color(0xFFF5F6F8);
  static const Color surfaceContainerHigh = Color(0xFFDFE1E7);
  static const Color surfaceDim = Color(0xFFE8EAF0);

  // ── On Surface ──
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color onBackground = Color(0xFF0F172A);

  // ── Outline ──
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);

  // ── Inverse ──
  static const Color inverseSurface = Color(0xFF1E293B);
  static const Color inversePrimary = Color(0xFFFFB800);
  static const Color inverseOnSurface = Color(0xFFF8FAFC);

  // ── Surface Tint ──
  static const Color surfaceTint = Color(0xFFFFB800);

  // ── Semantic / App-specific ──
  static const Color navInactive = Color(0xFF94A3B8); // slate-400
  static const Color navActive = Color(0xFFFFB800);
  static const Color cardBorder = Color(0x66FFFFFF); // white/40%
  static const Color glassBg = Color(0xB3FFFFFF); // white/70%
  static const Color glassNavBg = Color(0x66FFFFFF); // white/40%
  static const Color shimmer = Color(0x1AFFB800); // primary/10%

  // ── Profile specific ──
  static const Color profilePrimary = Color(0xFFF5A623);

  // ── Shadow colors ──
  static const Color shadowNav = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color shadowPrimary = Color(0x66FFB800); // rgba(255,184,0,0.4)
  static const Color shadowSubtle = Color(0x0F000000); // rgba(0,0,0,0.06)
}
