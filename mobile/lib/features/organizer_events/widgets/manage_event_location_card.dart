import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

class ManageEventLocationCard extends StatelessWidget {
  final EventModel event;

  const ManageEventLocationCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.imageUrl.trim();

    return Container(
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isEmpty)
            Container(color: AppColors.surfaceVariant)
          else
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 1200,
              maxWidthDiskCache: 1800,
              color: Colors.black.withValues(alpha: 0.25),
              colorBlendMode: BlendMode.darken,
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.surfaceVariant),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa điểm sự kiện',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.location.isNotEmpty
                      ? event.location
                      : 'Chưa có địa điểm',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
