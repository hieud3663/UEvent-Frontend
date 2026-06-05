// File: lib/features/event_shared/widgets/ticket_detail_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/image_cache_key.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class TicketDetailCard extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final String userTypeAndDate;
  final String questionText;
  final String eventTag;

  const TicketDetailCard({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.userTypeAndDate,
    required this.questionText,
    required this.eventTag,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = avatarUrl.trim();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + User Info
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                      image: normalizedAvatarUrl.isEmpty
                          ? null
                          : DecorationImage(
                              image: CachedNetworkImageProvider(
                                normalizedAvatarUrl,
                                cacheKey: stableImageCacheKey(
                                  imageUrl: normalizedAvatarUrl,
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 10,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userTypeAndDate.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navInactive,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Question Body
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: Text(
              questionText,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Event Tag Feature
          Row(
            children: [
              const Icon(
                Icons.event_available,
                size: 16,
                color: AppColors.navInactive,
              ),
              const SizedBox(width: 8),
              Text(
                eventTag.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navInactive,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
