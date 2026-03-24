// File: lib/features/events/views/event_detail_screen.dart
//
// Event Detail — Unregistered User.
// CTA: "Register Now" with price. No bottom nav.

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_constants.dart';
// mock_event_data and event_model kept for future data binding
import '../mock/mock_event_questions.dart';
import 'package:frontend/features/events/widgets/event_hero_header.dart';
import 'package:frontend/features/events/widgets/event_info_row.dart';
import 'package:frontend/features/events/widgets/event_organizer_card.dart';
import 'package:frontend/features/events/widgets/event_qa_section.dart';
import 'package:frontend/features/events/widgets/event_action_bar.dart';

class EventDetailScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final VoidCallback? onRegister;
  final VoidCallback? onAskQuestion;

  const EventDetailScreen({
    super.key,
    this.onBack,
    this.onShare,
    this.onRegister,
    this.onAskQuestion,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isFavourited = false;

  static const _organizerAvatars = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA1vKi1oHMg6_dl9xhiW7b2bwhzyjlRY_HJaEdNI1nm6Oz7UFCToEY2qcuIMXDNS0Jrxb66teq7Od1aN8OVVzLdHPrDdmboMU_KBQqRk5OXdq6_FPwdL0H_jCNE9b55oXq-YL2z-5ATwdBV1r-SzAZOC-Xb23-QdZWsgW6OQ-OZYDktj4dX3vQIn_wzl47Nr-GF0XA98hElVGbsnMfylrw7VUZed3tKe_fOY6uflHtz5W1KqrRhogGpDKH5AiUf7I2eGpjr2jBf0AA',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC8b_KswTJcj25j5WaMQycFiiyrLzpjZbeAwiRJ1NlWGkkG7mcTMI5qCZNwcqq8hH2WO6FnH1FdjPmpvt016s_flN3AGnlnb6Wxc1aC_gVVX0BPT0XE299i7rBdPXSedi6cr1r-mM20plKJrKjcx-MG98XAAPipKuilIm-bRiN3Z3DcH59U1jKQu4y59gsrlT91qB4V8REyeWtVpxDpNWksawqQMjlSp-KvowGVvYMHYrsHGDlVqRd1LEQZOS_7couPi_oQdhsHVJ0',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAtO4QG-JFTWgJWsfv5gcl44HVaRHK8Y8tcs0gFN4pOocsmg5FqGBFTchHHRzv2lyMiTdamKxkArer9TWYCVAvCkPExt5k7W2HKr7HOmUMNINHBUcpCuej_VT_jzN0kQveLx6ClX-KPQTwOhlmeSWSxeSH3_CI16TA3yoUPnudumY5oLD9wLhBPCSvcPo88Rl3F9MRb91u3pzGH4RL_sREt1U6K1GgKPRwMhZx4HwzJjoRlFR5fX0dvQbhge0PP35J3aBFUthLUFE',
  ];

  static const _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDv1e03VeVm-BUcyfnUDOdSOuOJW12Gl0RiCdSsFva1jZH5bzlRw-ZfBnlv_Z2ewQbLHStJZCLK0WVaw0W64l4HvLNCYf-gtgOFy8HYnq-rYv7In-vsngvmDEP5dfsOnRS83keS0g-69HUFFJfdy_nYtmCudMxf9IwykzrcwfijU-OW02DFnXkKvyMFaWJMiBYRlEw0cNzDUZIqopVVWdiC20UHx70AMDPqGApecw_d5BXDVjbTD8icBS8DX3C9kVNLBgqJhS3QFfA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero image with overlay buttons
              SliverToBoxAdapter(
                child: EventHeroHeader(
                  imageUrl: _heroImageUrl,
                  onBack: widget.onBack,
                  onShare: widget.onShare,
                  onFavourite: () =>
                      setState(() => _isFavourited = !_isFavourited),
                  isFavourited: _isFavourited,
                ),
              ),

              // Body card — rounded top
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pagePaddingH,
                      24,
                      AppConstants.pagePaddingH,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        _buildCategoryBadge(),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          'Global Developer Summit 2024: The AI Frontier',
                          style: AppTextStyles.headlineLarge
                              .copyWith(fontSize: 26, height: 1.2),
                        ),
                        const SizedBox(height: 20),
                        // Date + Location
                        EventInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Friday, Nov 15, 2024',
                          subtitle: '09:00 AM – 06:00 PM',
                        ),
                        const SizedBox(height: 12),
                        EventInfoRow(
                          icon: Icons.location_on,
                          label: 'Moscone Center West',
                          subtitle: '800 Howard St, San Francisco, CA',
                          onTap: () {},
                        ),
                        const SizedBox(height: 20),
                        // Organizer card
                        EventOrganizerCard(
                          organizerAvatarUrls: _organizerAvatars,
                          extraOrganizersCount: 12,
                          organizerName: 'UEvents Global Team',
                          onFollow: () {},
                        ),
                        const SizedBox(height: 24),
                        // About section
                        _buildAboutSection(),
                        const SizedBox(height: 24),
                        // Q&A section
                        EventQaSection(
                          questions: MockEventQuestions.questions,
                          totalCount: 24,
                          onAskQuestion: widget.onAskQuestion,
                          onViewAll: () {},
                        ),
                        // Bottom space for the fixed bar
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Fixed bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: EventActionBar(
              mode: EventActionBarMode.unregistered,
              price: '\$199.00',
              onRegister: widget.onRegister,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        'TECHNOLOGY',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Event', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Join over 5,000 developers and innovators from around the world for a day of deep dives into the future of artificial intelligence, machine learning, and cloud infrastructure.\n\n'
          "This year's summit features keynote speakers from industry leaders including OpenAI, Google, and Meta.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        ...['30+ Technical Workshops', 'Live Coding Sessions',
            'Exclusive AI Networking Lounge', 'Evening Rooftop Gala']
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7, right: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      ],
    );
  }
}
