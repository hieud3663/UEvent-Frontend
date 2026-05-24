// File: lib/features/profile/views/user_profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_container.dart';

class UserProfileView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const UserProfileView({super.key, this.onBack});

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  int _selectedTab = 0;
  final _tabs = ['Created', 'Upcoming', 'Finished'];

  @override
  Widget build(BuildContext context) {
    final profileOverviewAsync = ref.watch(profileOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ...profileOverviewAsync.when(
                data: (overview) {
                  final filteredEvents = _filterEventsByTab(overview.events);

                  return [
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(
                        name: overview.user.fullName,
                        studentCode: overview.user.studentCode ?? '---',
                        faculty: overview.user.faculty ?? '---',
                        className: overview.user.className ?? '---',
                        avatarUrl: overview.user.avatarUrl,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildStats(
                          eventCount: overview.events.length,
                          clubCount: 0,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTabs(),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    AppSuccessSliver(
                      isEmpty: filteredEvents.isEmpty,
                      emptyIcon: Icons.event_busy,
                      emptyTitle: 'No events',
                      emptyDescription: 'There are no events in this tab yet.',
                      emptyPadding: const EdgeInsets.symmetric(horizontal: 24),
                      contentSlivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildEventList(filteredEvents),
                          ),
                        ),
                      ],
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ];
                },
                loading: () => const [AppLoadingSliver()],
                error: (error, stackTrace) => [
                  AppErrorSliver(
                    title: 'Cannot load profile',
                    description: 'Please try again.',
                    onRetry: () => ref.refresh(profileOverviewProvider),
                    fillRemaining: true,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'PROFILE',
              titleStyle: AppTextStyles.titleMedium.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
              leadingIcon: Icons.close,
              trailingIcon: Icons.more_vert,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String studentCode,
    required String faculty,
    required String className,
    required String? avatarUrl,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: AppColors.shadowNav, blurRadius: 20),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppColors.surfaceVariant),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.profilePrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.headlineLarge),
        const SizedBox(height: 4),
        Text(
          'MSSV: $studentCode',
          style: AppTextStyles.labelSmall.copyWith(letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            faculty,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          className,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive),
        ),
      ],
    );
  }

  Widget _buildStats({required int eventCount, required int clubCount}) {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('$eventCount', style: AppTextStyles.statNumber),
                const SizedBox(height: 4),
                Text(
                  'EVENTS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('$clubCount', style: AppTextStyles.statNumber),
                const SizedBox(height: 4),
                Text(
                  'CLUBS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 12,
      child: Row(
        children: List.generate(
          _tabs.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedTab == i
                      ? [
                          BoxShadow(
                            color: AppColors.shadowSubtle,
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: _selectedTab == i
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedTab == i
                        ? AppColors.profilePrimary
                        : AppColors.navInactive,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    return Column(
      children: events
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassContainer(
                borderRadius: 12,
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          e.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: AppColors.surfaceVariant),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: AppColors.navInactive,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, y').format(e.startDate),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.navInactive,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: e.status == EventStatus.active
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    _statusText(e.status),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: e.status == EventStatus.active
                                          ? AppColors.primary
                                          : AppColors.navInactive,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.more_vert,
                                  size: 16,
                                  color: AppColors.navInactive,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  List<EventModel> _filterEventsByTab(List<EventModel> events) {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0:
        return events.where((event) => event.isOrganizer).toList();
      case 1:
        return events.where((event) => event.startDate.isAfter(now)).toList();
      case 2:
        return events
            .where(
              (event) =>
                  event.status == EventStatus.finished ||
                  event.startDate.isBefore(now),
            )
            .toList();
      default:
        return events;
    }
  }

  String _statusText(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return 'Active';
      case EventStatus.approved:
        return 'Approved';
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.finished:
        return 'Finished';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }
}
