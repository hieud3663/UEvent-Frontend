// File: lib/features/event_shared/widgets/share_action_grid.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// 4-icon action grid for Copy Link / Share via QR / Save Post / More.
class ShareActionGrid extends StatelessWidget {
  final VoidCallback? onCopyLink;
  final VoidCallback? onQrCode;
  final VoidCallback? onSavePost;
  final VoidCallback? onMore;

  const ShareActionGrid({
    super.key,
    this.onCopyLink,
    this.onQrCode,
    this.onSavePost,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(
          icon: Icons.link,
          label: 'Copy Link',
          isPrimary: true,
          onTap: onCopyLink,
        ),
        _ActionItem(icon: Icons.qr_code_2, label: 'Share QR', onTap: onQrCode),
        _ActionItem(
          icon: Icons.save_alt,
          label: 'Save Post',
          onTap: onSavePost,
        ),
        _ActionItem(icon: Icons.more_horiz, label: 'More', onTap: onMore),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: isPrimary
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: isPrimary ? Colors.white : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
