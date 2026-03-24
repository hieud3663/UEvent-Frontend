// File: lib/features/events/views/ask_question_screen.dart
//
// Ask a Question — task-focused form screen.
// Pushed via Navigator, no bottom nav.

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class AskQuestionScreen extends StatefulWidget {
  final String eventName;
  final String eventImageUrl;
  final String eventCategory;
  final VoidCallback? onBack;
  final void Function(String question, bool isAnonymous, bool wantsNotification)?
      onSend;

  const AskQuestionScreen({
    super.key,
    this.eventName = 'Future of Web3 & AI in Entertainment',
    this.eventImageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB1jXzh2I8WvzIkfdY-pDri-qHZOm4VuTsi_6k_AYtrtasQRQRey13PHsvB-wIGDb7Ydc-B1bU9clGOnuZPtsUY1bcrFGI-R_tesF8kVqeRTNDsnuW3CV430zYNN1l4MrxiH7Y2dBpMNK1A5luELCSjnF3YC-HEYWXXzTS5zIf6HJ7THn3OTFg-vuE8_FzMNgdzcKp6rxuJbgj7NRPjJuO2SQpT3I8ohI4rTOALWS5bPz67wmCANcCbNZPfnSao75dy_pufJSeB_mc',
    this.eventCategory = 'Live Q&A Session',
    this.onBack,
    this.onSend,
  });

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _controller = TextEditingController();
  bool _isAnonymous = false;
  bool _wantsNotification = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    widget.onSend?.call(q, _isAnonymous, _wantsNotification);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Glass top app bar ──
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.7),
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            elevation: 1,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Ask a Question',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24), // spacer for symmetry
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Context card ──
                  _buildContextCard(),
                  const SizedBox(height: 24),
                  // ── Question form card ──
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  // ── Footer note ──
                  Text(
                    'BY SENDING THIS QUESTION, YOU AGREE TO OUR COMMUNITY GUIDELINES. QUESTIONS ARE MODERATED FOR QUALITY.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Event thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                widget.eventImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventCategory.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.eventName,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Textarea label
          Text(
            'YOUR QUESTION',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // Textarea
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Toggle rows
          _buildToggleRow(
            icon: Icons.visibility_off_outlined,
            iconBg: AppColors.primaryContainer,
            iconColor: AppColors.onPrimaryContainer,
            title: 'Ask Anonymously',
            subtitle: 'Hide your name from the audience',
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v),
          ),
          const SizedBox(height: 16),
          _buildToggleRow(
            icon: Icons.notifications_active_outlined,
            iconBg: AppColors.secondaryContainer,
            iconColor: AppColors.secondary,
            title: 'Notify me on answer',
            subtitle: 'Get a ping when the speaker responds',
            value: _wantsNotification,
            onChanged: (v) => setState(() => _wantsNotification = v),
          ),
          const SizedBox(height: 24),
          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSend,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.outline),
        ),
      ],
    );
  }
}
