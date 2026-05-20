// File: lib/features/ticketing/views/my_tickets_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/async_state_slivers.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/providers/ticketing_providers.dart';
import 'package:frontend/features/ticketing/widgets/ticket_list_card.dart';
import 'package:frontend/features/ticketing/widgets/past_ticket_card.dart';
import 'package:frontend/features/ticketing/widgets/tickets_tab_bar.dart';

/// Tab 2 — My Tickets main screen.
/// Shows Upcoming / Past ticket lists with a segmented tab switcher.
class MyTicketsView extends ConsumerStatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final ValueChanged<TicketModel>? onTicketTap;
  final ValueChanged<TicketModel>? onPastTicketTap;
  final VoidCallback? onScanTap;

  const MyTicketsView({
    super.key,
    this.currentNavIndex = 2,
    required this.onNavTap,
    this.onTicketTap,
    this.onPastTicketTap,
    this.onScanTap,
  });

  @override
  ConsumerState<MyTicketsView> createState() => _MyTicketsViewState();
}

class _MyTicketsViewState extends ConsumerState<MyTicketsView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final upcomingAsync = ref.watch(upcomingTicketsProvider);
    final pastAsync = ref.watch(pastTicketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Spacing below fixed top bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // Tab bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: TicketsTabBar(
                    selectedIndex: _tabIndex,
                    onTabChanged: (i) => setState(() => _tabIndex = i),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Conditional content
              if (_tabIndex == 0) ..._buildUpcomingContent(upcomingAsync),
              if (_tabIndex == 1) ..._buildPastContent(pastAsync),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // Fixed Glass Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'My Tickets',
              titleStyle: AppTextStyles.titleLarge,
              trailingIcon: Icons.qr_code_scanner,
              onTrailingTap: widget.onScanTap,
            ),
          ),

          // Glass Bottom Nav Bar
          GlassBottomNavBar(
            currentIndex: widget.currentNavIndex,
            onTap: widget.onNavTap,
            items: GlassBottomNavBar.defaultItems,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUpcomingContent(
    AsyncValue<List<TicketModel>> ticketsAsync,
  ) {
    return ticketsAsync.when(
      data: (tickets) {
        return [
          AppSuccessSliver(
            isEmpty: tickets.isEmpty,
            emptyIcon: Icons.confirmation_number_outlined,
            emptyTitle: 'No Upcoming Tickets',
            emptyDescription: 'Your registered event tickets will appear here.',
            emptyFillRemaining: true,
            contentSlivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: Text(
                    '${tickets.length} upcoming event${tickets.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                      vertical: 6,
                    ),
                    child: TicketListCard(
                      ticket: ticket,
                      onTap: widget.onTicketTap != null
                          ? () => widget.onTicketTap!(ticket)
                          : null,
                    ),
                  );
                }, childCount: tickets.length),
              ),
            ],
          ),
        ];
      },
      loading: () => const [AppLoadingSliver(padding: EdgeInsets.zero)],
      error: (error, stackTrace) => [
        AppErrorSliver(
          title: 'Cannot load tickets',
          description: 'Please check your network and try again.',
          onRetry: () => ref.refresh(upcomingTicketsProvider),
          retryText: 'Retry',
        ),
      ],
    );
  }

  List<Widget> _buildPastContent(AsyncValue<List<TicketModel>> ticketsAsync) {
    return ticketsAsync.when(
      data: (tickets) {
        return [
          AppSuccessSliver(
            isEmpty: tickets.isEmpty,
            emptyIcon: Icons.history,
            emptyTitle: 'No Past Events',
            emptyDescription: 'Events you have attended will appear here.',
            emptyFillRemaining: true,
            contentSlivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pagePaddingH,
                  ),
                  child: _buildSummaryBanner(tickets.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                      vertical: 6,
                    ),
                    child: PastTicketCard(
                      ticket: ticket,
                      onTap: widget.onPastTicketTap != null
                          ? () => widget.onPastTicketTap!(ticket)
                          : null,
                    ),
                  );
                }, childCount: tickets.length),
              ),
            ],
          ),
        ];
      },
      loading: () => const [AppLoadingSliver(padding: EdgeInsets.zero)],
      error: (error, stackTrace) => [
        AppErrorSliver(
          title: 'Cannot load past tickets',
          description: 'Please check your network and try again.',
          onRetry: () => ref.refresh(pastTicketsProvider),
          retryText: 'Retry',
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(int attendedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You attended $attendedCount event${attendedCount > 1 ? 's' : ''}.',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
