// File: lib/features/event_shared/widgets/quick_reply_bar.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class QuickReplyBar extends StatelessWidget {
  final List<String> replies;
  final ValueChanged<String> onSelectReply;

  const QuickReplyBar({
    super.key,
    required this.replies,
    required this.onSelectReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // Fixed height for horizontal list wrapper
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: replies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final replyText = replies[index];
          return GestureDetector(
            onTap: () => onSelectReply(replyText),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Text(
                replyText,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
