// File: lib/features/events/views/send_notification_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/glass_filter_chip.dart';
import 'package:frontend/features/events/widgets/recipient_selection_card.dart';

class SendNotificationView extends StatefulWidget {
  final VoidCallback? onBack;

  const SendNotificationView({
    super.key,
    this.onBack,
  });

  @override
  State<SendNotificationView> createState() => _SendNotificationViewState();
}

class _SendNotificationViewState extends State<SendNotificationView> {
  int _selectedRecipientIndex = 0;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // ── Recipient Selection ──
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: Text(
                        'RECIPIENTS',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RecipientSelectionCard(
                            icon: Icons.group,
                            title: 'All Participants',
                            subtitle: '428 members',
                            isSelected: _selectedRecipientIndex == 0,
                            onTap: () {
                              setState(() {
                                _selectedRecipientIndex = 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RecipientSelectionCard(
                            icon: Icons.account_tree,
                            title: 'Specific Groups',
                            subtitle: 'Select segments',
                            isSelected: _selectedRecipientIndex == 1,
                            onTap: () {
                              setState(() {
                                _selectedRecipientIndex = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Notification Content ──
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 16),
                      child: Text(
                        'NOTIFICATION CONTENT',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    
                    // Subject Input
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _subjectController,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Subject',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.navInactive),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Glass Text Area
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 8,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Your message...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.navInactive),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        GlassFilterChip(
                          label: 'Schedule for later',
                          isActive: false,
                          onTap: () {},
                        ),
                        GlassFilterChip(
                          label: 'Add Attachment',
                          isActive: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // ── Action Button ──
                    PrimaryButton(
                      label: 'Send Notification',
                      icon: Icons.send,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Your message will be sent as a push notification and email to all recipients immediately.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.secondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),
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
              title: 'Send Notification',
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
