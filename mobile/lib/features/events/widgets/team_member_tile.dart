// File: lib/features/events/widgets/team_member_tile.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

enum TeamRole { admin, staff, volunteer }

class TeamMemberTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final TeamRole role;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TeamMemberTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.role,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine Role Styling
    Color tagBgColor;
    Color tagTextColor;
    Border? tagBorder;
    String tagLabel;

    switch (role) {
      case TeamRole.admin:
        tagBgColor = AppColors.primary.withValues(alpha: 0.15);
        tagTextColor = AppColors.primary;
        tagLabel = 'ADMIN';
        break;
      case TeamRole.staff:
        tagBgColor = AppColors.surfaceVariant;
        tagTextColor = AppColors.onSurfaceVariant;
        tagLabel = 'STAFF';
        break;
      case TeamRole.volunteer:
        tagBgColor = Colors.white;
        tagTextColor = AppColors.navInactive.withValues(alpha: 0.6);
        tagBorder = Border.all(color: AppColors.surfaceVariant, width: 1);
        tagLabel = 'VOLUNTEER';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar with Admin Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  if (role == TeamRole.admin)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.stars,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Name & Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      border: tagBorder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tagLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: tagTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Row actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.navInactive,
                iconSize: 20,
                splashRadius: 24,
                onPressed: onEdit,
                hoverColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.navInactive,
                iconSize: 20,
                splashRadius: 24,
                onPressed: onDelete,
                hoverColor: AppColors.error.withValues(alpha: 0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
