// File: lib/features/events/views/attendee_list_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/glass_search_bar.dart';
import 'package:frontend/core/widgets/glass_filter_chip.dart';
import 'package:frontend/features/events/widgets/attendee_card.dart';

class AttendeeListView extends StatefulWidget {
  final VoidCallback? onBack;

  const AttendeeListView({
    super.key,
    this.onBack,
  });

  @override
  State<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends State<AttendeeListView> {
  int _activeFilterIndex = 0; // 0: All, 1: Checked-in, 2: Pending

  final List<String> _filters = ['All', 'Checked-in', 'Pending'];

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
                    
                    // ── Search & Title ──
                    Text(
                      'Attendee List',
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    const GlassSearchBar(
                      placeholder: 'Search by name or ID...',
                    ),
                    const SizedBox(height: 24),

                    // ── Filter Chips ──
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          return GlassFilterChip(
                            label: _filters[index],
                            isActive: _activeFilterIndex == index,
                            onTap: () {
                              setState(() {
                                _activeFilterIndex = index;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Attendee List ──
                    if (_activeFilterIndex == 0 || _activeFilterIndex == 1) ...[
                      const AttendeeCard(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCpzviU0JepTi67QRjWGMFzY8zCjpX_K7hvHAr8jurH_Wap3XnhP7WZ14L4_EruMjEwPM4Pwf-TXyeVPIVvHdAW5Tcre7v6ZtEZZ88dcdw7b98TFnQlzLyxW2sJ7ACHN5YVnB2TKeFmK0pOR1-8NKQJI1Ip-NTRsAsTJ7gxnFP5zLvFEugTq4LMGErSEZgux3b-ecj4q_SfmnGGr7IHuCjHQ38oJfoUNTmnW99GLdMttYwMWcWugz4v54gZOgq-RJdvTKUBEPRglSU',
                        name: 'Marcus Thorne',
                        studentId: '#STU-99210',
                        status: AttendeeStatus.checkedIn,
                        timestamp: '10:45 AM',
                      ),
                    ],
                    if (_activeFilterIndex == 0 || _activeFilterIndex == 2) ...[
                      const AttendeeCard(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-VPgzuSzHltRef-1Pxn7uiYgA4x-KnRKq4EZaXUYq1NTVZb1vPBEBJj0o0sY-WDkJ-MEjmHWv8otwGHn5X2Mx6_lLnPl6dwvC8mEg08DtiqBSSG_93rtH8MBxSXOvtpSL9HP9QYfnat3IBP7QcPKwXs-mOp9WBiCuyY8Nx7xe7UNv5xLKtXSc4enRV8BQxn57V9kmpByI0xrmDOAYUZDWNhx7C8u_O6bEFI5uwcCCDsSIi-IIEfnEzi4n1yWAs-L0u4XMNP6vMAc',
                        name: 'Elena Rodriguez',
                        studentId: '#STU-88234',
                        status: AttendeeStatus.pending,
                      ),
                    ],
                    if (_activeFilterIndex == 0 || _activeFilterIndex == 1) ...[
                      const AttendeeCard(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC9nLVeF1HhZPKgEkQDfh7m_wOrVGQWTjmNUYBnMOy4PCKlNSvmOvwtQksEEAcMo6m1tw_Ol_Es_9XiD7cfRgHlLaVz07BtzQVxkvwUeKXADl791RMqKaZ0sfA8ztBieYi2vvsRr_vEQGeshMAS8dqi8-_UXhJbzNMakJHSOxYAOGYNW9N8Uqghg5ijubiutArDHM_EoG90AS_mK3HWpGIoB4EdMrBnkKMDp8gk1Q3XlgmDt85NCGm6X0o_TrpbNYNN9PtOTpwh8MU',
                        name: 'Julian Chen',
                        studentId: '#STU-44102',
                        status: AttendeeStatus.checkedIn,
                        timestamp: '09:12 AM',
                      ),
                    ],
                    if (_activeFilterIndex == 0 || _activeFilterIndex == 2) ...[
                      const AttendeeCard(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmx1DPPCz1QzKFwrizuImhmO1LtiYumoTKt7xQJbiL2njrvVkLdVSxeuQjxTWfw6QSAP4NCIpJSzFY0TgUj0ZST6aoItyyW7j3p0MtfpDVLm7yaWIwgeDWQiCau1KoM4z6PZDmYoumrKSJ1D2dE3F3QK1WCuYmO9Mj0RpxC7DTsrXOc9wVNyHyO5qmt9XdLCltIcZZeQRvOhzz4mvj1m3MbBKQHrHBU9yBjvJOER3FQy2U3I3g0Eiz0rq367U_PHYSxua9G2deKxc',
                        name: 'Sarah Jenkins',
                        studentId: '#STU-11903',
                        status: AttendeeStatus.pending,
                      ),
                    ],
                    if (_activeFilterIndex == 0 || _activeFilterIndex == 1) ...[
                      const AttendeeCard(
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBuicVyOp1XOvXfyI2hsF_90SfIGeT7DkaWb5BaVqgD7W1I4XIZxBypaxGTRRw4vGiWYpQy2fzSq4O1rR6GZ_txy2FYWz8ZpqoQlXMmAcjeo1jIbKO9F9pzkQrcpJISjE-vArQNYB2lOcCQ7M81tzUG90d19Y9yxJk9zhADGM6_WXUUvoE7s4F1ZQD2e0WQ5HDsFsDPDTITmrjj9jbtgC2xf8CsUu4yiKTOPIr0hi5kKyO49pSfOTOO3r7OoykQTWSkSoV4FAvfhJ8',
                        name: 'David Osei',
                        studentId: '#STU-77541',
                        status: AttendeeStatus.checkedIn,
                        timestamp: '11:02 AM',
                      ),
                    ],
                    const SizedBox(height: 100), // Bottom padding

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
              leadingIcon: Icons.close,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
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
