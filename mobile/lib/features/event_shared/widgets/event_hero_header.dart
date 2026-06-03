// File: lib/features/event_shared/widgets/event_hero_header.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';

/// Full-bleed hero image with gradient overlay + back/share/favourite overlay buttons.
/// Returns a SliverAppBar or use as a plain widget inside CustomScrollView.
class EventHeroHeader extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onFavourite;
  final bool isFavourited;

  const EventHeroHeader({
    super.key,
    required this.imageUrl,
    this.onBack,
    this.onShare,
    this.onFavourite,
    this.isFavourited = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 353,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          if (imageUrl.trim().isEmpty)
            const _HeroImagePlaceholder()
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 1400,
              maxWidthDiskCache: 1920,
              placeholder: (context, url) => const _HeroImagePlaceholder(),
              errorWidget: (context, url, error) =>
                  const _HeroImagePlaceholder(),
            ),
          // Gradient fade to background at bottom
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  AppColors.background,
                  Colors.transparent,
                  Color(0x33000000),
                ],
              ),
            ),
          ),
          // Top controls row
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _GlassCircleButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: onBack ?? () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _GlassCircleButton(icon: Icons.share, onTap: onShare),
                    const SizedBox(width: 8),
                    _GlassCircleButton(
                      icon: isFavourited
                          ? Icons.favorite
                          : Icons.favorite_border,
                      onTap: onFavourite,
                      iconColor: isFavourited ? Colors.red : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _GlassCircleButton({required this.icon, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: icon,
      iconSize: 20,
      iconColor: iconColor ?? AppColors.onSurface,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      onPressed: onTap,
    );
  }
}

class _HeroImagePlaceholder extends StatelessWidget {
  const _HeroImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 56,
        color: AppColors.outline,
      ),
    );
  }
}
