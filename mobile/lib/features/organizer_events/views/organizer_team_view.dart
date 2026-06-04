import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/async_state_widgets.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/event_shared/models/event_organizer_member_model.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/providers/organizer_event_providers.dart';

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
                      _OrganizerSearchField(
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
                        data: (organizers) => _OrganizerList(
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
      builder: (sheetContext) => _AddOrganizerSheet(eventId: widget.eventId),
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

class _AddOrganizerSheet extends ConsumerStatefulWidget {
  final String eventId;

  const _AddOrganizerSheet({required this.eventId});

  @override
  ConsumerState<_AddOrganizerSheet> createState() => _AddOrganizerSheetState();
}

class _AddOrganizerSheetState extends ConsumerState<_AddOrganizerSheet> {
  final _emailController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thêm BTC', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Nhập email tài khoản UEvent để cấp quyền co-host.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GlassInputField(
                label: 'Email',
                placeholder: 'name@example.com',
                leadingIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Thêm BTC',
                icon: Icons.person_add_alt_1,
                isLoading: _isAdding,
                onPressed: _isAdding ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAppSnackBar(context, 'Vui lòng nhập email.');
      return;
    }

    setState(() => _isAdding = true);

    final ok = await ref
        .read(organizerEventMutationControllerProvider.notifier)
        .addOrganizerByEmail(eventId: widget.eventId, email: email);

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    showAppSnackBar(
      context,
      'Không thêm được BTC. Vui lòng kiểm tra email và quyền owner.',
    );
  }
}

class _OrganizerSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _OrganizerSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 18,
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, email hoặc vai trò',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasQuery) ...[
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.close,
              iconSize: 18,
              size: 32,
              onPressed: onClear,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrganizerList extends StatelessWidget {
  final List<EventOrganizerMemberModel> organizers;
  final String searchQuery;
  final String? removingOrganizerId;
  final ValueChanged<EventOrganizerMemberModel> onRemove;

  const _OrganizerList({
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
            child: _OrganizerMemberTile(
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

class _OrganizerMemberTile extends StatelessWidget {
  final EventOrganizerMemberModel organizer;
  final bool isRemoving;
  final VoidCallback? onRemove;

  const _OrganizerMemberTile({
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
