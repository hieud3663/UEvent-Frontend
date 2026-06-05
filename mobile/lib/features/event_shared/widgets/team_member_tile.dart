// File: lib/features/event_shared/widgets/team_member_tile.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/team_member_model.dart';
import 'package:frontend/core/widgets/glass_container.dart';

/// Reusable tile widget for displaying a team/staff member.
/// Used in Event Detail's BTC Team section and Manage Team screen.
class TeamMemberTile extends StatelessWidget {
  final TeamMemberModel member;
  final VoidCallback? onTap;

  const TeamMemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 12,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: member.avatarUrl,
                cacheKey: member.stableAvatarCacheKey,
                fit: BoxFit.cover,
                memCacheWidth: 96,
                maxWidthDiskCache: 192,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name + Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.role,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.navInactive,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
