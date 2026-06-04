import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

class ManageEventBadge extends StatelessWidget {
  final EventStatus status;
  final VoidCallback? onTap;

  const ManageEventBadge({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.tune,
      onPressed: onTap,
      backgroundColor: _statusColor.withValues(alpha: 0.12),
      iconColor: _statusColor,
      size: 56,
    );
  }

  Color get _statusColor {
    return switch (status) {
      EventStatus.active => AppColors.primary,
      EventStatus.approved => AppColors.primary,
      EventStatus.draft => AppColors.primaryDark,
      EventStatus.finished => AppColors.success,
      EventStatus.cancelled => AppColors.error,
    };
  }
}
