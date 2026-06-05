// File: lib/features/profile/views/user_profile_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/segmented_toggle.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/profile/providers/profile_providers.dart';

class UserProfileView extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onEditProfile;
  final ValueChanged<EventModel>? onEventTap;

  const UserProfileView({
    super.key,
    this.onBack,
    this.onEditProfile,
    this.onEventTap,
  });

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  int _selectedTab = 0;
  final _tabs = ['Đã tạo', 'Sắp diễn ra', 'Đã kết thúc'];

  @override
  Widget build(BuildContext context) {
    final profileOverviewAsync = ref.watch(profileOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProfileOverview,
            child: CustomScrollView(
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
                          avatarCacheKey: overview.user.stableAvatarCacheKey,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildStats(
                            eventCount: overview.events.length,
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
                        emptyTitle: _emptyTitle,
                        emptyDescription: _emptyDescription,
                        emptyPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        contentSlivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
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
                      title: 'Không tải được hồ sơ',
                      description: 'Vui lòng thử lại.',
                      onRetry: () => ref.refresh(profileOverviewProvider),
                      fillRemaining: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'HỒ SƠ',
              titleStyle: AppTextStyles.titleMedium.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
              leadingIcon: Icons.close,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProfileOverview() {
    ref.invalidate(profileOverviewProvider);
    return ref.refresh(profileOverviewProvider.future);
  }

  Widget _buildProfileHeader({
    required String name,
    required String studentCode,
    required String faculty,
    required String className,
    required String? avatarUrl,
    required String? avatarCacheKey,
  }) {
    final normalizedAvatarUrl = avatarUrl?.trim() ?? '';

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
                child: normalizedAvatarUrl.isEmpty
                    ? Container(color: AppColors.surfaceVariant)
                    : CachedNetworkImage(
                        imageUrl: normalizedAvatarUrl,
                        cacheKey: avatarCacheKey,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Container(color: AppColors.surfaceVariant),
                      ),
              ),
            ),
            GlassIconButton(
              icon: Icons.edit,
              size: 32,
              iconSize: 14,
              backgroundColor: AppColors.profilePrimary,
              iconColor: Colors.white,
              onPressed: widget.onEditProfile,
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

  Widget _buildStats({required int eventCount}) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('$eventCount', style: AppTextStyles.statNumber),
          const SizedBox(height: 4),
          Text(
            'SỰ KIỆN',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.navInactive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Center(
      child: SegmentedToggle(
        options: _tabs,
        selectedIndex: _selectedTab,
        onSelect: (index) => setState(() => _selectedTab = index),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    return Column(
      children: events
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => widget.onEventTap?.call(e),
                  borderRadius: BorderRadius.circular(12),
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
                            child: CachedNetworkImage(
                              imageUrl: e.imageUrl,
                              cacheKey: e.imageCacheKey,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
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
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(e.startDate.toLocal()),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.navInactive,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      child: Text(
                                        _statusText(e.status),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color:
                                                  e.status == EventStatus.active
                                                  ? AppColors.primary
                                                  : AppColors.navInactive,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 18,
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
              ),
            ),
          )
          .toList(),
    );
  }

  String get _emptyTitle {
    switch (_selectedTab) {
      case 0:
        return 'Chưa tạo sự kiện';
      case 1:
        return 'Chưa có sự kiện sắp diễn ra';
      case 2:
        return 'Chưa có sự kiện đã kết thúc';
      default:
        return 'Chưa có sự kiện';
    }
  }

  String get _emptyDescription {
    switch (_selectedTab) {
      case 0:
        return 'Các sự kiện bạn tạo sẽ xuất hiện tại đây.';
      case 1:
        return 'Sự kiện bạn tham gia hoặc tổ chức trong tương lai sẽ xuất hiện tại đây.';
      case 2:
        return 'Sự kiện đã hoàn tất sẽ được lưu lại tại đây.';
      default:
        return 'Không có sự kiện trong mục này.';
    }
  }

  bool _isPastEvent(EventModel event, DateTime now) {
    if (event.status == EventStatus.finished) return true;
    final endDate = event.endDate;
    if (endDate != null) return endDate.isBefore(now);
    return event.startDate.isBefore(now);
  }

  bool _isUpcomingEvent(EventModel event, DateTime now) {
    if (event.status == EventStatus.finished ||
        event.status == EventStatus.cancelled) {
      return false;
    }

    final endDate = event.endDate;
    if (endDate != null) return endDate.isAfter(now);
    return event.startDate.isAfter(now);
  }

  bool _isCreatedEvent(EventModel event) => event.canManageCurrentUser;

  bool _isProfileEvent(EventModel event) {
    return event.canManageCurrentUser || event.isRegisteredByCurrentUser;
  }

  List<EventModel> _filterEventsByTab(List<EventModel> events) {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0:
        return events.where(_isCreatedEvent).toList();
      case 1:
        return events
            .where(
              (event) => _isProfileEvent(event) && _isUpcomingEvent(event, now),
            )
            .toList();
      case 2:
        return events
            .where(
              (event) => _isProfileEvent(event) && _isPastEvent(event, now),
            )
            .toList();
      default:
        return events.where(_isProfileEvent).toList();
    }
  }

  String _statusText(EventStatus status) {
    switch (status) {
      case EventStatus.active:
        return 'Đang hoạt động';
      case EventStatus.approved:
        return 'Đã duyệt';
      case EventStatus.draft:
        return 'Nháp';
      case EventStatus.finished:
        return 'Đã kết thúc';
      case EventStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
