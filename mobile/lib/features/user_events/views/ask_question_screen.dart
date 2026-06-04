// File: lib/features/user_events/views/ask_question_screen.dart
//
// Ask a Question — task-focused form screen.
// Pushed via Navigator, no bottom nav.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_container.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/glass_toggle_tile.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/core/widgets/primary_button.dart';

class AskQuestionScreen extends StatefulWidget {
  final String eventName;
  final String eventImageUrl;
  final String eventCategory;
  final VoidCallback? onBack;
  final Future<bool> Function(
    String question,
    bool isAnonymous,
    bool wantsNotification,
  )?
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
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final ok =
        await widget.onSend?.call(q, _isAnonymous, _wantsNotification) ?? true;
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSending = false;
      _errorMessage = 'Không gửi được câu hỏi. Vui lòng thử lại.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContextCard(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                      const SizedBox(height: 16),
                      Text(
                        'Câu hỏi sẽ được kiểm duyệt để giữ chất lượng thảo luận.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassTopBar(
              title: 'Đặt câu hỏi',
              leadingIcon: Icons.chevron_left,
              onLeadingTap: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: widget.eventImageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 180,
                maxWidthDiskCache: 320,
                errorWidget: (context, url, error) =>
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
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassInputField(
            label: 'Câu hỏi của bạn',
            placeholder: 'Nhập câu hỏi của bạn...',
            leadingIcon: Icons.help_outline,
            controller: _controller,
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: 20,
            child: Column(
              children: [
                GlassToggleTile(
                  title: 'Hỏi ẩn danh',
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v),
                ),
                GlassToggleTile(
                  title: 'Thông báo khi có trả lời',
                  value: _wantsNotification,
                  showDivider: false,
                  onChanged: (v) => setState(() => _wantsNotification = v),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Gửi câu hỏi',
            icon: Icons.send,
            isLoading: _isSending,
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
