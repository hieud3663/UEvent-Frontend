// File: lib/widgets/glass_input_field.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Glassmorphic input field used in Create Event screen.
/// Shows label above and input/child below within a frosted glass panel.
class GlassInputField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final IconData? leadingIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? child;
  final Widget? trailing;

  const GlassInputField({
    super.key,
    required this.label,
    this.placeholder,
    this.leadingIcon,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                label.toUpperCase(),
                style: AppTextStyles.inputLabel,
              ),
              const SizedBox(height: 4),

              // Input or child
              if (child != null)
                child!
              else
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(
                        leadingIcon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: placeholder,
                          hintStyle: AppTextStyles.inputHint,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
