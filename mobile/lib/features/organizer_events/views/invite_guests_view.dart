// File: lib/features/organizer_events/views/invite_guests_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_search_bar.dart';
import 'package:frontend/core/widgets/glass_filter_chip.dart';
import 'package:frontend/features/event_shared/widgets/guest_invitation_card.dart';

class InviteGuestsView extends StatefulWidget {
  final VoidCallback? onBack;

  const InviteGuestsView({super.key, this.onBack});

  @override
  State<InviteGuestsView> createState() => _InviteGuestsViewState();
}

class _InviteGuestsViewState extends State<InviteGuestsView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Students',
    'Computer Science',
    'Design',
    'Business',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePaddingH,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Search Bar
                    GlassSearchBar(
                      placeholder: 'Search students by name or ID...',
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 24),

                    // Horizontal Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GlassFilterChip(
                              label: _filters[index],
                              isActive: _selectedFilterIndex == index,
                              onTap: () {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Student List
                    GuestInvitationCard(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDqCeiq--EbPPj06RfRs203xE1RHZyambF6galGPZSwqebETfCXWSUBEjdBOwxAfiuh4ivcO1V3FSphXSVU6Fe_WqodSgCDO6mwgBy9CkllPHMYEbZFHbkAJgmE5YAFy4TpjaCGL7KKK4AxVFMzhC6uo80aUSXmiNhVHxaUkHnh_nXSNI5O_psvwRzS7D_GnemMrJxy1GG26mPHTbP9k0zTp_z93mgkMlaNcdanmJP12DaDpZGjnu7AKrhPlN5mG0C46jXvB0-iSjA',
                      name: 'Marcus Chen',
                      id: 'CS-2024-089',
                      isInvited: false,
                      onInvite: () {},
                    ),
                    GuestInvitationCard(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBvQ6J79qA5s22SQZPwCd9d8gI8peq5Ha18D0DNm4P9gMObmzQ0GYK9Xebi4J9Hzqt6HEjX1GBLuMXK5SNlGYJdmU8hobq6BMIBsmgUwlKgewIyqYb5dHr2FjvrY5ia3tLedJn5fOsVY9bJmcATHpCWolBkXiY-dXFiXPSNV-SAcs7qGW7D7y5w36BOUQonZ2pmpLBgkdTzFxNbou8lX_BmpvLtxK9b0g7vpyxiEQXSQ4gFhZw2XL3Iu8BQcEzf2OlVWmXf3s0lWf4',
                      name: 'Elena Rodriguez',
                      id: 'DS-2024-112',
                      isInvited: true,
                      onInvite: () {},
                    ),
                    GuestInvitationCard(
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCmJHlW7cnUFAIj8kltUXNifNGT6UQ8VKRGgp3mqxLuys-j5SffPAUscekhDPNpOYWxi198n3_dSGIG0RnYKkkq4dj62S2JyLQDBenVQeEjwjImmFylRTIV8bdn5BqqGe3ebFuYPSaZvWLAb_ebjsGFEv4XixMGg2VZsmDhW6fCAv5p_2t_DJ_-ytcIck-M1VCW7otuuyHgZ38lFC84MVHLI6527ui4EifVp4leAg-ztF_BShDFdwwPA-gIYlabj5p5IOpzDDu0tIU',
                      name: 'Jordan Smith',
                      id: 'BU-2024-441',
                      isInvited: false,
                      onInvite: () {},
                    ),
                    GuestInvitationCard(
                      imageUrl: '',
                      name: 'Alex Morgan',
                      id: 'DS-2024-772',
                      isInvited: false,
                      onInvite: () {},
                    ),

                    const SizedBox(height: 100),
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
              title: 'Invite Guests',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: IconButton(
                icon: const Icon(Icons.more_horiz, color: AppColors.onSurface),
                onPressed: () {},
                splashRadius: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
