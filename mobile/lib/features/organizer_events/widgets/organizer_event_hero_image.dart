import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_detail_formatters.dart';

class OrganizerEventHeroImage extends StatelessWidget {
  final EventModel event;

  const OrganizerEventHeroImage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (event.imageUrl.trim().isEmpty)
            const _HeroImageFallback()
          else
            CachedNetworkImage(
              imageUrl: event.imageUrl,
              cacheKey: event.imageCacheKey,
              fit: BoxFit.cover,
              memCacheWidth: 1200,
              maxWidthDiskCache: 1800,
              errorWidget: (_, _, _) => const _HeroImageFallback(),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: 9999,
              child: Text(
                organizerEventStatusLabel(event.status).toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}
