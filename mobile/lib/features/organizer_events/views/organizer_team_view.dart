import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_team_add_sheet.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_team_list.dart';
import 'package:frontend/features/organizer_events/widgets/organizer_team_search_field.dart';

class OrganizerTeamView extends ConsumerStatefulWidget {
  final String eventId;
  final VoidCallback? onBack;

  const OrganizerTeamView({super.key, required this.eventId, this.onBack});

  @override
  ConsumerState<OrganizerTeamView> createState() => _OrganizerTeamViewState();
}

class _OrganizerTeamViewState extends ConsumerState<OrganizerTeamView> {
  final _searchController = TextEditingController();
  String? _removingOrganizerId;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizersState = ref.watch(
      organizerEventOrganizersProvider(widget.eventId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.refresh(
              organizerEventOrganizersProvider(widget.eventId).future,
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'Danh sách BTC',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quản lý người đồng tổ chức bằng email tài khoản UEvent.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Thêm BTC',
                        icon: Icons.person_add_alt_1,
                        onPressed: _showAddOrganizerSheet,
                      ),
                      const SizedBox(height: 16),
                      OrganizerTeamSearchField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _searchQuery = value.trim());
                        },
                        onClear: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                      const SizedBox(height: 24),
                      organizersState.when(
                        loading: () => const AppLoadingState(
                          height: 220,
                          padding: EdgeInsets.zero,
                        ),
                        error: (_, _) => AppErrorState(
                          title: 'Không tải được danh sách BTC',
                          description: 'Vui lòng kiểm tra quyền và thử lại.',
                          padding: EdgeInsets.zero,
                          onRetry: () => ref.invalidate(
                            organizerEventOrganizersProvider(widget.eventId),
                          ),
                        ),
                        data: (organizers) => OrganizerTeamList(
                          organizers: organizers,
                          searchQuery: _searchQuery,
                          removingOrganizerId: _removingOrganizerId,
                          onRemove: _removeOrganizerWithConfirm,
                        ),
                      ),
                      const SizedBox(height: 48),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Đội ngũ BTC',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: GlassIconButton(
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(
                  organizerEventOrganizersProvider(widget.eventId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddOrganizerSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => OrganizerTeamAddSheet(eventId: widget.eventId),
    );
    if (!mounted) return;

    if (added == true) {
      showAppSnackBar(context, 'Đã thêm BTC.');
    }
  }

  Future<void> _removeOrganizerWithConfirm(
    EventOrganizerMemberModel organizer,
  ) async {
    final email = organizer.user.email.trim();
    if (email.isEmpty) {
      showAppSnackBar(context, 'BTC này chưa có email để xóa.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa BTC'),
        content: Text('Xóa ${organizer.user.displayName} khỏi đội ngũ BTC?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _removingOrganizerId = organizer.id);
    final ok = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .removeOrganizerByEmail(eventId: widget.eventId, email: email);

    if (!mounted) return;
    setState(() => _removingOrganizerId = null);

    showAppSnackBar(
      context,
      ok
          ? 'Đã xóa BTC khỏi sự kiện.'
          : 'Không xóa được BTC. Vui lòng kiểm tra quyền owner.',
    );
  }
}
