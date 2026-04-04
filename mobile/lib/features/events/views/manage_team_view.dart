// File: lib/features/events/views/manage_team_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/events/widgets/team_member_tile.dart';
import 'package:frontend/features/events/widgets/info_bento_card.dart';
import 'package:frontend/features/events/mock/mock_manage_team_data.dart';
import 'package:frontend/features/events/models/team_member_model.dart';

class ManageTeamView extends StatelessWidget {
  final VoidCallback? onBack;

  const ManageTeamView({super.key, this.onBack});

  // Reference mock data
  static List<TeamMemberModel> get _teamMembers => MockManageTeamData.teamMembers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // ── Section Header ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TEAM MANAGEMENT',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'BTC Team',
                              style: AppTextStyles.headlineLarge.copyWith(fontSize: 32),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '${_teamMembers.length} Members',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Search & Filter Area ──
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.search, size: 20, color: AppColors.navInactive),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search team members...',
                                hintStyle: AppTextStyles.inputHint,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Add Button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_add, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Member',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Team List ──
                    ...List.generate(
                      _teamMembers.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TeamMemberTile(
                          member: _teamMembers[i],
                          onTap: () {
                            // TODO: Navigate to team member detail/edit
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Role Permissions Info Bento ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InfoBentoCard(
                            icon: Icons.security,
                            iconColor: AppColors.primary,
                            iconBgColor: AppColors.primary.withValues(alpha: 0.2),
                            borderColor: AppColors.primary.withValues(alpha: 0.3),
                            title: 'Role Permissions',
                            description: 'Admins can manage billing and team. Staff can manage events and guests. Volunteers are view-only for assignments.',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InfoBentoCard(
                            icon: Icons.group_add,
                            iconColor: AppColors.onSurfaceVariant,
                            iconBgColor: AppColors.surfaceVariant,
                            borderColor: AppColors.surfaceVariant,
                            title: 'Bulk Invite',
                            description: 'Need to add more than 10 people at once? Use our CSV importer tool.',
                            actionLabel: 'Try CSV Import',
                            onAction: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Bottom spacing

                  ]),
                ),
              ),
            ],
          ),

          // ── Fixed Top Bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Event Manager',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    // child: const Icon(Icons.search, size: 20, color: AppColors.onSurface),
                  ),
                  // const SizedBox(width: 8),
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  //     image: const DecorationImage(
                  //       image: NetworkImage(
                  //         'https://lh3.googleusercontent.com/aida-public/AB6AXuDFuL6NEAAge6fvYvVth0uzStI429Dajq-NiNb2nAYa4pRLMrPGGE8jJTsSmhEucJa4f-KUkkV_fGulm3rw929-C5H7dH3cmXfNMTEoXTKyrXxsuFoXPPxkX-oPo5r9Bi8QCDyBMwPOQyEKbe8GgpjXBpn9__L1Og6KGMrcyV2zK-XrMaSIkB26jAUNy4hCyz4V8gH2DQ2UR2Q59FgQ1BK66c2sMi0xU8YNhLQvUN34Ap8LkfTxpbh65tmQQEMKw6hz1ztwShbCCR8',
                  //       ),
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
