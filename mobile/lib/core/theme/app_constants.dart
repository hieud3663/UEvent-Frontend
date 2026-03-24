// File: lib/apps/app_constants.dart



/// Centralized spacing, dimensions and decoration constants
/// extracted from UEvents Stitch design.
class AppConstants {
  AppConstants._();

  // ── Padding & Margin ──
  static const double pagePaddingH = 16.0;
  static const double pagePaddingHLarge = 24.0;
  static const double sectionSpacing = 32.0;
  static const double cardSpacing = 16.0;
  static const double itemSpacing = 12.0;

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;
  static const double radiusNav = 32.0;
  static const double radiusCard = 24.0;
  static const double radiusInput = 24.0;

  // ── Sizes ──
  static const double topBarHeight = 56.0;
  static const double bottomNavHeight = 72.0;
  static const double bottomNavOffset = 32.0;
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 112.0;
  static const double notificationIconSize = 48.0;
  static const double eventThumbnailSize = 80.0;
  static const double fabHeight = 56.0;

  // ── Glass Effects ──
  static const double glassBlur = 20.0;
  static const double glassNavBlur = 25.0;
  static const double glassNavSaturation = 2.0;
  static const double glassOpacity = 0.7;
  static const double glassNavOpacity = 0.4;
  static const double glassBorderOpacity = 0.4;

  // ── Animations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Featured Card ──
  static const double featuredCardHeight = 320.0;
  static const double bentoCardHeight = 152.0;

  // ── Event Card Vertical ──
  static const double eventCardImageHeight = 224.0;
}
