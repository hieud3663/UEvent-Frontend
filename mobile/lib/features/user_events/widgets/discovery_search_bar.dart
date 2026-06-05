import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class DiscoverySearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const DiscoverySearchBar({
    super.key,
    this.value = '',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  State<DiscoverySearchBar> createState() => _DiscoverySearchBarState();
}

class _DiscoverySearchBarState extends State<DiscoverySearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DiscoverySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _controller.text) return;

    _controller
      ..text = widget.value
      ..selection = TextSelection.collapsed(offset: widget.value.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowSubtle, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.navInactive, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sự kiện...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.navInactive,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (widget.value.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            InkResponse(
              onTap: widget.onClear,
              radius: 18,
              child: Icon(Icons.close, color: AppColors.navInactive, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
