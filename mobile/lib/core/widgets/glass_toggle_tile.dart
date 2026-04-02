// File: lib/core/widgets/glass_toggle_tile.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class GlassToggleTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const GlassToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              CupertinoSwitch(
                value: value,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.outlineVariant,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.2),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
