// File: lib/features/events/widgets/event_organizer_card.dart

import 'package:flutter/material.dart';
import '../../../apps/app_colors.dart';
import '../../../apps/app_text_styles.dart';
import '../../../apps/app_constants.dart';

/// Organizer card: stacked avatar row + org name + Follow button.
class EventOrganizerCard extends StatelessWidget {
  final List<String> organizerAvatarUrls;
  final int extraOrganizersCount;
  final String organizerName;
  final VoidCallback? onFollow;

  const EventOrganizerCard({
    super.key,
    required this.organizerAvatarUrls,
    this.extraOrganizersCount = 0,
    required this.organizerName,
    this.onFollow,
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
            child: Stack(
              children: [
                ..._buildAvatarStack(),
              ],
            ),
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
                  'Organizers',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFollow,
            child: Text(
              'Follow',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Avatar width: each avatar is 40px wide, overlapping by 14px
  double get _stackWidth {
    final count = organizerAvatarUrls.length + (extraOrganizersCount > 0 ? 1 : 0);
    return 40 + (count - 1) * 26.0;
  }

  List<Widget> _buildAvatarStack() {
    final List<Widget> items = [];
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

  Widget _buildAvatar({String? url, String? label}) {
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
            ? Image.network(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariant))
            : Center(
                child: Text(
                  label ?? '',
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
