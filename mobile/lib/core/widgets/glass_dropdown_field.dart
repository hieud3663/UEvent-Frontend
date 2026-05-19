// File: lib/core/widgets/glass_dropdown_field.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Glassmorphic dropdown field matching GlassInputField design.
/// Shows a tappable field that opens a modal bottom sheet with options.
class GlassDropdownField<T> extends StatelessWidget {
  final String label;
  final String? placeholder;
  final T? value;
  final List<GlassDropdownItem<T>> items;
  final ValueChanged<T>? onChanged;
  final Widget? labelTrailing;

  const GlassDropdownField({
    super.key,
    required this.label,
    this.placeholder,
    this.value,
    required this.items,
    this.onChanged,
    this.labelTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final selectedItem = items.cast<GlassDropdownItem<T>?>().firstWhere(
      (item) => item?.value == value,
      orElse: () => null,
    );

    final content = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
      child: Ink(
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
        child: InkWell(
          onTap: () => _showBottomSheet(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (labelTrailing != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppTextStyles.inputLabel,
                      ),
                      labelTrailing!,
                    ],
                  )
                else
                  Text(label.toUpperCase(), style: AppTextStyles.inputLabel),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedItem?.label ?? placeholder ?? '',
                        style: selectedItem != null
                            ? AppTextStyles.bodyLarge
                            : AppTextStyles.inputHint,
                      ),
                    ),
                    AnimatedRotation(
                      turns: 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.outline,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
      child: isAndroid
          ? content
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: content,
            ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _GlassDropdownSheet<T>(
        label: label,
        items: items,
        selectedValue: value,
        onSelected: (val) {
          Navigator.of(ctx).pop();
          onChanged?.call(val);
        },
      ),
    );
  }
}

/// Single dropdown item data model.
class GlassDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const GlassDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Bottom sheet that displays the list of options.
class _GlassDropdownSheet<T> extends StatelessWidget {
  final String label;
  final List<GlassDropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _GlassDropdownSheet({
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final content = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                final isSelected = item.value == selectedValue;

                return Semantics(
                  button: true,
                  selected: isSelected,
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => onSelected(item.value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              if (item.icon != null) ...[
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: isAndroid
          ? content
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: content,
            ),
    );
  }
}
