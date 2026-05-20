// File: lib/features/events/views/registration_questions_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/events/widgets/registration_question_tile.dart';

class RegistrationQuestionsView extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onQuestionTap;

  const RegistrationQuestionsView({super.key, this.onBack, this.onQuestionTap});

  @override
  State<RegistrationQuestionsView> createState() =>
      _RegistrationQuestionsViewState();
}

class _RegistrationQuestionsViewState extends State<RegistrationQuestionsView> {
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
                    // ── Screen Header ──
                    Text(
                      'Registration Questions',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage what information attendees provide.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Questions List ──
                    RegistrationQuestionTile(
                      icon: Icons.checkroom, // apparel equivalent
                      title: 'T-shirt size',
                      typeAndRequirement: 'Dropdown • Required',
                      onView: widget.onQuestionTap,
                      onDelete: () {
                        // TODO: Show delete confirmation dialog
                      },
                    ),
                    RegistrationQuestionTile(
                      icon: Icons.restaurant,
                      title: 'Dietary needs',
                      typeAndRequirement: 'Multi-select • Optional',
                      onView: widget.onQuestionTap,
                      onDelete: () {
                        // TODO: Show delete confirmation dialog
                      },
                    ),
                    RegistrationQuestionTile(
                      icon: Icons.medical_services_outlined,
                      title: 'Emergency Contact',
                      typeAndRequirement: 'Short Answer • Required',
                      onView: widget.onQuestionTap,
                      onDelete: () {
                        // TODO: Show delete confirmation dialog
                      },
                    ),
                    RegistrationQuestionTile(
                      icon: Icons.accessible_forward,
                      title: 'Accessibility requirements',
                      typeAndRequirement: 'Long Answer • Optional',
                      onView: widget.onQuestionTap,
                      onDelete: () {
                        // TODO: Show delete confirmation dialog
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Global Settings ──
                    // Text(
                    //   'GLOBAL SETTINGS',
                    //   style: AppTextStyles.labelSmall.copyWith(
                    //     fontWeight: FontWeight.w700,
                    //     color: AppColors.navInactive,
                    //     letterSpacing: 1.5,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),

                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withValues(alpha: 0.7),
                    //     borderRadius: BorderRadius.circular(16),
                    //     border: Border.all(
                    //       color: Colors.white.withValues(alpha: 0.4),
                    //       width: 0.5,
                    //     ),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       GlassToggleTile(
                    //         title: 'Allow question skipping',
                    //         value: _allowSkipping,
                    //         onChanged: (val) {
                    //           setState(() {
                    //             _allowSkipping = val;
                    //           });
                    //         },
                    //         showDivider: true,
                    //       ),
                    //       GlassToggleTile(
                    //         title: 'Show questions after payment',
                    //         value: _showAfterPayment,
                    //         onChanged: (val) {
                    //           setState(() {
                    //             _showAfterPayment = val;
                    //           });
                    //         },
                    //         showDivider: false,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 100), // Bottom spacing
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
