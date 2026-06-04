import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

class ManageEventHeader extends StatelessWidget {
  final EventModel event;

  const ManageEventHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Quản lý sự kiện',
          style: AppTextStyles.headlineLarge.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          '${event.title} • ${event.location}',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.navInactive,
          ),
        ),
      ],
    );
  }
}
