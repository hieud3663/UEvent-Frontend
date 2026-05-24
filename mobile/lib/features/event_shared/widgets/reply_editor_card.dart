// File: lib/features/event_shared/widgets/reply_editor_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ReplyEditorCard extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onAttachment;
  final VoidCallback? onEmoji;
  final int maxLength;

  const ReplyEditorCard({
    super.key,
    this.controller,
    this.onChanged,
    this.onAttachment,
    this.onEmoji,
    this.maxLength = 2000,
  });

  @override
  State<ReplyEditorCard> createState() => _ReplyEditorCardState();
}

class _ReplyEditorCardState extends State<ReplyEditorCard> {
  late TextEditingController _internalController;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(_updateLength);
  }

  @override
  void dispose() {
    _internalController.removeListener(_updateLength);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _updateLength() {
    setState(() {
      _currentLength = _internalController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text input
          Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(minHeight: 220),
            child: TextField(
              controller: _internalController,
              onChanged: widget.onChanged,
              maxLines: null, // Makes it expand automatically
              keyboardType: TextInputType.multiline,
              maxLength: widget.maxLength,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null, // hide default counter
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.navInactive,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Toolbar Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onAttachment,
                      child: const Icon(
                        Icons.attachment,
                        color: AppColors.navInactive,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: widget.onEmoji,
                      child: const Icon(
                        Icons.mood,
                        color: AppColors.navInactive,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_currentLength / ${widget.maxLength}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.navInactive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
