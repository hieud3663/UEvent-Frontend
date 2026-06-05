import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';

class OrganizerTeamList extends StatelessWidget {
  final List<EventOrganizerMemberModel> organizers;
  final String searchQuery;
  final String? removingOrganizerId;
  final ValueChanged<EventOrganizerMemberModel> onRemove;

  const OrganizerTeamList({
    super.key,
    required this.organizers,
    required this.searchQuery,
    required this.removingOrganizerId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrganizers = _filterOrganizers();

    if (organizers.isEmpty) {
      return const AppSuccessState(
        isEmpty: true,
        emptyIcon: Icons.groups_2_outlined,
        emptyTitle: 'Chưa có BTC',
        emptyDescription: 'Thêm BTC bằng email tài khoản UEvent.',
        emptyPadding: EdgeInsets.zero,
        child: SizedBox.shrink(),
      );
    }

    if (filteredOrganizers.isEmpty) {
      return const AppSuccessState(
        isEmpty: true,
        emptyIcon: Icons.search_off,
        emptyTitle: 'Không tìm thấy BTC',
        emptyDescription: 'Thử tìm bằng tên, email hoặc vai trò khác.',
        emptyPadding: EdgeInsets.zero,
        child: SizedBox.shrink(),
      );
    }

    return Column(
      children: [
        for (final organizer in filteredOrganizers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrganizerTeamMemberTile(
              organizer: organizer,
              isRemoving: removingOrganizerId == organizer.id,
              onRemove: _removeActionFor(organizer),
            ),
          ),
      ],
    );
  }

  List<EventOrganizerMemberModel> _filterOrganizers() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return organizers;

    return organizers
        .where((organizer) {
          final role = _roleLabel(organizer.organizerRole).toLowerCase();
          return organizer.user.displayName.toLowerCase().contains(query) ||
              organizer.user.email.toLowerCase().contains(query) ||
              role.contains(query);
        })
        .toList(growable: false);
  }

  VoidCallback? _removeActionFor(EventOrganizerMemberModel organizer) {
    if (_isOwner(organizer) || removingOrganizerId != null) return null;
    return () => onRemove(organizer);
  }

  bool _isOwner(EventOrganizerMemberModel organizer) {
    return organizer.organizerRole.trim().toLowerCase() == 'owner';
  }

  String _roleLabel(String role) {
    return switch (role.trim().toLowerCase()) {
      'owner' => 'Owner',
      'co_host' => 'Co-host',
      'staff' => 'Staff',
      'checkin' => 'Check-in',
      _ => role,
    };
  }
}

class OrganizerTeamMemberTile extends StatelessWidget {
  final EventOrganizerMemberModel organizer;
  final bool isRemoving;
  final VoidCallback? onRemove;

  const OrganizerTeamMemberTile({
    super.key,
    required this.organizer,
    this.isRemoving = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: organizer.user.avatarUrl,
              cacheKey: organizer.user.stableAvatarCacheKey,
              fit: BoxFit.cover,
              memCacheWidth: 96,
              maxWidthDiskCache: 192,
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizer.user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  organizer.user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                _RolePill(label: _roleLabel(organizer.organizerRole)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isRemoving)
            const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            GlassIconButton(
              icon: Icons.delete_outline,
              iconColor: onRemove == null
                  ? AppColors.navInactive
                  : AppColors.error,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return switch (role.trim().toLowerCase()) {
      'owner' => 'Owner',
      'co_host' => 'Co-host',
      'staff' => 'Staff',
      'checkin' => 'Check-in',
      _ => role,
    };
  }
}

class _RolePill extends StatelessWidget {
  final String label;

  const _RolePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
