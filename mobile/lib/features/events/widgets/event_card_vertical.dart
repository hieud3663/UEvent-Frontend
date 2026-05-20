// File: lib/widgets/event_card_vertical.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:intl/intl.dart';

/// Vertical event card used in Discovery screen.
/// Full-width image with date badge, title, location, and time info.
class EventCardVertical extends StatelessWidget {
  final EventModel event;
  final String dateBadge;
  final VoidCallback? onTap;

  const EventCardVertical({
    super.key,
    required this.event,
    required this.dateBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSubtle,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with date badge
            Stack(
              children: [
                SizedBox(
                  height: AppConstants.eventCardImageHeight,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 900,
                    maxWidthDiskCache: 1400,
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                ),
                // Date badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                    ),
                    child: Text(
                      dateBadge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, event.location),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.schedule,
                    event.timeRange ??
                        '${DateFormat('HH:mm').format(event.startDate)} - ${DateFormat('HH:mm').format(event.endDate ?? event.startDate)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.navInactive),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navInactive,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
