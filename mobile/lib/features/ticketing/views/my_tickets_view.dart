// File: lib/features/ticketing/views/my_tickets_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/empty_state_view.dart';
import 'package:frontend/features/ticketing/mock/mock_ticket_data.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/widgets/ticket_list_card.dart';
import 'package:frontend/features/ticketing/widgets/past_ticket_card.dart';
import 'package:frontend/features/ticketing/widgets/tickets_tab_bar.dart';

/// Tab 2 — My Tickets main screen.
/// Shows Upcoming / Past ticket lists with a segmented tab switcher.
class MyTicketsView extends StatefulWidget {
  final int currentNavIndex;
  final ValueChanged<int> onNavTap;
  final ValueChanged<TicketModel>? onTicketTap;
  final ValueChanged<TicketModel>? onPastTicketTap;

  const MyTicketsView({
    super.key,
    this.currentNavIndex = 2,
    required this.onNavTap,
    this.onTicketTap,
    this.onPastTicketTap,
  });

  @override
  State<MyTicketsView> createState() => _MyTicketsViewState();
}

class _MyTicketsViewState extends State<MyTicketsView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              if (_tabIndex == 0) ..._buildUpcomingContent(),
              if (_tabIndex == 1) ..._buildPastContent(),

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
              trailingIcon: Icons.settings_outlined,
              onTrailingTap: () {},
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

  List<Widget> _buildUpcomingContent() {
    final tickets = MockTicketData.upcomingTickets;
    if (tickets.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: EmptyStateView(
              icon: Icons.confirmation_number_outlined,
              title: 'No Upcoming Tickets',
              description: 'Your registered event tickets will appear here.',
            ),
          ),
        ),
      ];
    }
    return [
      // Section label
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
          child: Text(
            '${tickets.length} upcoming event${tickets.length > 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: tickets.length,
        ),
      ),
    ];
  }

  List<Widget> _buildPastContent() {
    final tickets = MockTicketData.pastTickets;
    if (tickets.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: EmptyStateView(
              icon: Icons.history,
              title: 'No Past Events',
              description: 'Events you have attended will appear here.',
            ),
          ),
        ),
      ];
    }
    return [
      // Attendance summary banner
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
          child: _buildSummaryBanner(),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      // Past ticket cards
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: tickets.length,
        ),
      ),
    ];
  }

  Widget _buildSummaryBanner() {
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
            child: const Icon(Icons.emoji_events, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              MockTicketData.attendanceSummary,
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
