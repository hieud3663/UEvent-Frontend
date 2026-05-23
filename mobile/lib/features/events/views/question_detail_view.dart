// File: lib/features/events/views/question_detail_view.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/app_snack_bar.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/events/widgets/ticket_detail_card.dart';
import 'package:frontend/features/events/widgets/reply_editor_card.dart';
import 'package:frontend/features/events/widgets/quick_reply_bar.dart';

class QuestionDetailView extends StatefulWidget {
  final VoidCallback? onBack;

  const QuestionDetailView({super.key, this.onBack});

  @override
  State<QuestionDetailView> createState() => _QuestionDetailViewState();
}

class _QuestionDetailViewState extends State<QuestionDetailView> {
  final TextEditingController _replyController = TextEditingController();

  final List<String> _quickReplies = [
    'Quick: Ticket Policy',
    'Quick: App Guide',
    'Contact Support',
  ];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _insertQuickReply(String reply) {
    setState(() {
      final currentText = _replyController.text;
      if (currentText.isEmpty) {
        _replyController.text = reply;
      } else {
        _replyController.text = '$currentText\n$reply';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine bottom padding dynamically to avoid keyboard overflow
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                    // ── Attendee Question Detail ──
                    const TicketDetailCard(
                      avatarUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBq83ddJFxOl0xv5HYwFn1d8a_7Tv9rQZFEQFBr_qHzuQOE0ZMRGDk5v4Yyat9Tp__uS_DRyYFFj2gpNWLJtZLJTohxnpvEBCmJhu-BLJxvEibrv-FOJtsT0I6xl80ODmYaZXhxe5Gd0v4mlQtrtLxN9G97M8UEAzO821iRDe98y_v1q1bHJ_AJYx9qq0MxqE2HXIcjsdi0aw6kHVHdloOd2w4Y-Xg4s0OZW53kwkSNnUzQz96r2fA_gvYy6GRRSB7A7zAZMz0__7o',
                      userName: 'Michael Chen',
                      userTypeAndDate: 'Regular Attendee • 2m ago',
                      questionText: 'How do I update my emergency contact?',
                      eventTag: 'Tech Summit 2024',
                    ),
                    const SizedBox(height: 32),

                    // ── Organizer Reply Section ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOUR RESPONSE',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navInactive,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'DRAFT SAVED',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navInactive,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ReplyEditorCard(
                      controller: _replyController,
                      onAttachment: () {
                        // mock
                      },
                      onEmoji: () {
                        // mock
                      },
                    ),
                    const SizedBox(height: 16),

                    // Send Button
                    PrimaryButton(
                      label: 'Send Reply',
                      icon: Icons.send,
                      onPressed: () {
                        showAppSnackBar(context, 'Reply sent!');
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'THIS WILL BE VISIBLE ONLY TO MICHAEL CHEN',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.navInactive,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                    ),

                    // Spacer for keyboard and floating bottom bar
                    SizedBox(height: bottomPadding > 0 ? bottomPadding : 120),
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
              title: 'Question Detail',
              leadingIcon: Icons.close,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
              trailingWidget: IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
                onPressed: () {},
                splashRadius: 24,
              ),
            ),
          ),

          // ── Quick Reply Bottom Bar (Floating) ──
          Positioned(
            bottom: bottomPadding > 0
                ? bottomPadding + 16
                : 32, // Lift above keyboard if open
            left: 16,
            right: 16,
            child: QuickReplyBar(
              replies: _quickReplies,
              onSelectReply: _insertQuickReply,
            ),
          ),
        ],
      ),
    );
  }
}
