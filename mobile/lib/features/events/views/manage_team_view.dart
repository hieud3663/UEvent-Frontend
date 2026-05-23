// File: lib/features/events/views/manage_team_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_search_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/events/controller/event_mutation_controller.dart';
import 'package:frontend/features/events/models/event_model.dart';
import 'package:frontend/features/events/models/event_registration_model.dart';
import 'package:frontend/features/events/models/team_member_model.dart';
import 'package:frontend/features/events/providers/event_providers.dart';
import 'package:frontend/features/events/widgets/info_bento_card.dart';
import 'package:frontend/features/events/widgets/team_member_tile.dart';

class ManageTeamView extends ConsumerStatefulWidget {
  final String eventId;
  final VoidCallback? onBack;

  const ManageTeamView({super.key, required this.eventId, this.onBack});

  @override
  ConsumerState<ManageTeamView> createState() => _ManageTeamViewState();
}

class _ManageTeamViewState extends ConsumerState<ManageTeamView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(organizerEventDetailProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: detailState.when(
                  loading: () => const SliverToBoxAdapter(
                    child: AppLoadingState(
                      height: 260,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  error: (_, _) => SliverToBoxAdapter(
                    child: AppErrorState(
                      title: 'Không tải được team',
                      description: 'Vui lòng kiểm tra quyền owner/organizer.',
                      padding: EdgeInsets.zero,
                      onRetry: () => ref.invalidate(
                        organizerEventDetailProvider(widget.eventId),
                      ),
                    ),
                  ),
                  data: (event) => SliverList(
                    delegate: SliverChildListDelegate(_content(context, event)),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Event Manager',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: GlassIconButton(
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(
                  organizerEventDetailProvider(widget.eventId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, EventModel event) {
    final teamMembers = _filteredMembers(event);

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
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
          ),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 999,
            child: Text(
              '${event.organizers.length} Members',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: GlassSearchBar(
              placeholder: 'Search team members...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(width: 12),
          PrimaryButton(
            label: 'Add',
            icon: Icons.person_add,
            isFullWidth: false,
            onPressed: () => _showPromoteCohostSheet(context),
          ),
        ],
      ),
      const SizedBox(height: 32),
      if (teamMembers.isEmpty)
        const AppSuccessState(
          isEmpty: true,
          emptyIcon: Icons.groups_outlined,
          emptyTitle: 'Chưa có team member',
          emptyDescription: 'Owner và co-host sẽ hiển thị tại đây.',
          emptyPadding: EdgeInsets.zero,
          child: SizedBox.shrink(),
        )
      else
        ...teamMembers.map(
          (member) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TeamMemberTile(member: member),
          ),
        ),
      const SizedBox(height: 32),
      InfoBentoCard(
        icon: Icons.group_add,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primary.withValues(alpha: 0.2),
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        title: 'Add Co-host',
        description:
            'Co-host chỉ được cấp từ user đã đăng ký sự kiện theo API hiện tại.',
      ),
      const SizedBox(height: 100),
    ];
  }

  List<TeamMemberModel> _filteredMembers(EventModel event) {
    final query = _query.trim().toLowerCase();

    return event.organizers
        .map(
          (organizer) => TeamMemberModel(
            id: organizer.id,
            name: organizer.user.displayName,
            role: organizer.organizerRole,
            avatarUrl: organizer.user.avatarUrl,
          ),
        )
        .where((member) {
          if (query.isEmpty) return true;
          return '${member.name} ${member.role}'.toLowerCase().contains(query);
        })
        .toList();
  }

  void _showPromoteCohostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, sheetRef, _) {
          final registrationsState = sheetRef.watch(
            eventRegistrationsProvider(widget.eventId),
          );
          final mutationState = sheetRef.watch(
            eventRegistrationControllerProvider,
          );

          return SafeArea(
            top: false,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.72,
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: registrationsState.when(
                loading: () => const AppLoadingState(
                  height: 220,
                  padding: EdgeInsets.zero,
                ),
                error: (_, _) => AppErrorState(
                  title: 'Không tải được đăng ký',
                  description: 'Vui lòng thử lại.',
                  padding: EdgeInsets.zero,
                  onRetry: () => sheetRef.invalidate(
                    eventRegistrationsProvider(widget.eventId),
                  ),
                ),
                data: (registrations) {
                  final candidates = registrations
                      .where((registration) => registration.canPromoteToCohost)
                      .toList();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Add Co-host', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 12),
                      Expanded(
                        child: candidates.isEmpty
                            ? const AppSuccessState(
                                isEmpty: true,
                                emptyIcon: Icons.person_search,
                                emptyTitle: 'Không có ứng viên',
                                emptyDescription:
                                    'User cần đăng ký event trước khi được cấp co-host.',
                                emptyPadding: EdgeInsets.zero,
                                child: SizedBox.shrink(),
                              )
                            : ListView.separated(
                                itemCount: candidates.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, index) => _CandidateTile(
                                  registration: candidates[index],
                                  isLoading: mutationState.isLoading,
                                  onPromote: () => _promoteCandidate(
                                    ctx,
                                    sheetRef,
                                    candidates[index],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _promoteCandidate(
    BuildContext sheetContext,
    WidgetRef ref,
    EventRegistrationModel registration,
  ) async {
    final ok = await ref
        .read(eventRegistrationControllerProvider.notifier)
        .promoteRegistrationToCohost(
          eventId: widget.eventId,
          registrationId: registration.id,
        );

    if (!mounted || !sheetContext.mounted) return;
    if (ok) {
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cấp quyền co-host.')));
    } else {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        const SnackBar(content: Text('Không cấp được quyền co-host.')),
      );
    }
  }
}

class _CandidateTile extends StatelessWidget {
  final EventRegistrationModel registration;
  final bool isLoading;
  final VoidCallback onPromote;

  const _CandidateTile({
    required this.registration,
    required this.isLoading,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    final user = registration.user;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.surfaceVariant,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Unknown attendee',
                  style: AppTextStyles.titleSmall,
                ),
                Text(
                  user?.email ?? registration.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: 'Co-host',
            isFullWidth: false,
            isLoading: isLoading,
            onPressed: onPromote,
          ),
        ],
      ),
    );
  }
}
