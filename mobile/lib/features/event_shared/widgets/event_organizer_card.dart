// File: lib/features/event_shared/widgets/event_organizer_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_constants.dart';

/// Organizer card: stacked avatar row + org name + Follow button.
class EventOrganizerCard extends StatelessWidget {
  final List<String> organizerAvatarUrls;
  final int extraOrganizersCount;
  final String organizerName;
  final String fallbackAvatarLabel;
  final VoidCallback? onFollow;
  final bool isFollowing;

  const EventOrganizerCard({
    super.key,
    required this.organizerAvatarUrls,
    this.extraOrganizersCount = 0,
    required this.organizerName,
    this.fallbackAvatarLabel = '',
    this.onFollow,
    this.isFollowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
      ),
      child: Row(
        children: [
          // Stacked avatars
          SizedBox(
            width: _stackWidth,
            height: 40,
            child: Stack(children: [..._buildAvatarStack()]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizerName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Ban tổ chức',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFollow,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFollowing
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isFollowing
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFollowing
                          ? Icons.notifications_active
                          : Icons.person_add_alt_1,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
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

  // Avatar width: each avatar is 40px wide, overlapping by 14px
  double get _stackWidth {
    final visibleAvatarCount = organizerAvatarUrls.isEmpty
        ? 1
        : organizerAvatarUrls.length;
    final count = visibleAvatarCount + (extraOrganizersCount > 0 ? 1 : 0);
    if (count <= 1) return 40;
    return 40 + (count - 1) * 26.0;
  }

  List<Widget> _buildAvatarStack() {
    final List<Widget> items = [];
    if (organizerAvatarUrls.isEmpty) {
      items.add(
        Positioned(left: 0, child: _buildAvatar(label: _fallbackInitials)),
      );
      if (extraOrganizersCount > 0) {
        items.add(
          Positioned(
            left: 26,
            child: _buildAvatar(label: '+$extraOrganizersCount'),
          ),
        );
      }
      return items;
    }

    for (int i = 0; i < organizerAvatarUrls.length; i++) {
      items.add(
        Positioned(
          left: i * 26.0,
          child: _buildAvatar(url: organizerAvatarUrls[i]),
        ),
      );
    }
    if (extraOrganizersCount > 0) {
      items.add(
        Positioned(
          left: organizerAvatarUrls.length * 26.0,
          child: _buildAvatar(label: '+$extraOrganizersCount'),
        ),
      );
    }
    return items;
  }

  String get _fallbackInitials {
    final normalized = fallbackAvatarLabel.trim().isNotEmpty
        ? fallbackAvatarLabel.trim()
        : organizerName.trim();
    if (normalized.isEmpty) return 'BTC';

    final parts = normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.length >= 2) {
      return '${parts.first.characters.first}${parts.last.characters.first}'
          .toUpperCase();
    }
    return normalized.characters.take(2).join().toUpperCase();
  }

  Widget _buildAvatar({String? url, String? label}) {
    final avatarLabel = label ?? _fallbackInitials;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.background, width: 2),
        color: AppColors.surfaceVariant,
      ),
      child: ClipOval(
        child: url != null
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: 96,
                maxWidthDiskCache: 192,
                errorWidget: (_, _, _) => _AvatarFallback(label: avatarLabel),
              )
            : Center(
                child: Text(
                  avatarLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String label;

  const _AvatarFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
