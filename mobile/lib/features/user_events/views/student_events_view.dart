import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/models/nav_item_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/section_header.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';
import 'package:frontend/features/event_shared/widgets/event_card_vertical.dart';
import 'package:frontend/features/user_events/providers/user_event_providers.dart';

class StudentEventsView extends ConsumerWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final ValueChanged<EventModel>? onEventTap;
  final List<NavItemModel> navItems;

  const StudentEventsView({
    super.key,
    this.currentNavIndex = 1,
    required this.onNavTap,
    this.onEventTap,
    this.navItems = GlassBottomNavBar.defaultItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userRegisteredEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref
                .refresh(userRegisteredEventsProvider.future)
                .then<void>((_) {}),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ...eventsAsync.when(
                  data: (events) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.pagePaddingH,
                        ),
                        child: SectionHeader(
                          title: 'Sự kiện của tôi',
                          actionText: '${events.length} EVENT',
                          onActionTap: () {},
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    AppSuccessSliver(
                      isEmpty: events.isEmpty,
                      emptyIcon: Icons.event_busy_outlined,
                      emptyTitle: 'Chưa đăng ký sự kiện',
                      emptyDescription:
                          'Các sự kiện bạn đã đăng ký sẽ xuất hiện tại đây.',
                      emptyFillRemaining: true,
                      contentSlivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.pagePaddingH,
                                vertical: 12,
                              ),
                              child: EventCardVertical(
                                event: event,
                                dateBadge: DateFormat(
                                  'MMM d',
                                ).format(event.startDate),
                                onTap: onEventTap == null
                                    ? null
                                    : () => onEventTap!(event),
                              ),
                            );
                          }, childCount: events.length),
                        ),
                      ],
                    ),
                  ],
                  loading: () => const [AppLoadingSliver()],
                  error: (_, _) => [
                    AppErrorSliver(
                      icon: Icons.wifi_off,
                      title: 'Không tải được sự kiện',
                      description: 'Vui lòng kiểm tra mạng và thử lại.',
                      onRetry: () =>
                          ref.invalidate(userRegisteredEventsProvider),
                    ),
                  ],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(title: 'Sự kiện'),
          ),
          GlassBottomNavBar(
            currentIndex: currentNavIndex,
            onTap: onNavTap,
            items: navItems,
          ),
        ],
      ),
    );
  }
}
