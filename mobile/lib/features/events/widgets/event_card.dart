// File: lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/core/widgets/glass_container.dart';

/// Horizontal event card used in Home (Your Events) and Profile screens.
/// Shows thumbnail, date, title, location, and optional trailing widget.
class EventCard extends StatelessWidget {
  final EventModel event;
  final String formattedDate;
  final Widget? trailing;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.formattedDate,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: AppConstants.eventThumbnailSize,
                height: AppConstants.eventThumbnailSize,
                fit: BoxFit.cover,
                memCacheWidth: 160,
                maxWidthDiskCache: 320,
                errorWidget: (context, url, error) => Container(
                  width: AppConstants.eventThumbnailSize,
                  height: AppConstants.eventThumbnailSize,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.event, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate.toUpperCase(),
                    style: AppTextStyles.dateTag,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.title,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing widget (e.g. QR code button)
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
