import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/event_shared/models/event_model.dart';

class OrganizerEventDescriptionSection extends StatelessWidget {
  final EventModel event;

  const OrganizerEventDescriptionSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final description = event.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mô tả sự kiện', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          description?.isNotEmpty == true
              ? description!
              : 'Chưa có mô tả sự kiện.',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
