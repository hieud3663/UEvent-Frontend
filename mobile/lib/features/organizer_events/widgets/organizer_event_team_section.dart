import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/models/team_member_model.dart';
import 'package:frontend/features/event_shared/widgets/team_member_tile.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_event_detail_formatters.dart';

class OrganizerEventTeamSection extends StatelessWidget {
  final EventModel event;
  final VoidCallback onViewAll;

  const OrganizerEventTeamSection({
    super.key,
    required this.event,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final teamMembers = event.organizers
        .map(
          (organizer) => TeamMemberModel(
            id: organizer.id,
            name: organizer.user.displayName,
            role: organizerRoleLabel(organizer.organizerRole),
            avatarUrl: organizer.user.avatarUrl,
          ),
        )
        .toList(growable: false);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Đội ngũ BTC', style: AppTextStyles.headlineMedium),
            ),
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.groups_2_outlined, size: 18),
              label: const Text('Xem tất cả'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (teamMembers.isEmpty)
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 12,
            child: Text(
              'Chưa có thành viên BTC nào.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(
            teamMembers.length,
            (i) => Padding(
              padding: EdgeInsets.only(
                bottom: i < teamMembers.length - 1 ? 12 : 0,
              ),
              child: TeamMemberTile(member: teamMembers[i]),
            ),
          ),
      ],
    );
  }
}
