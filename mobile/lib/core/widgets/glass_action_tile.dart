// File: lib/core/widgets/glass_action_tile.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class GlassActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;
  final Color? baseColor;

  const GlassActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right,
    this.baseColor,
  });

  @override
  State<GlassActionTile> createState() => _GlassActionTileState();
}

class _GlassActionTileState extends State<GlassActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.baseColor != null;
    final mainColor = widget.baseColor ?? AppColors.primary;
    final defaultBgColor = isWarning
        ? const Color(0xFFFEF2F2).withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.4);
    final hoverBgColor = isWarning
        ? const Color(0xFFFEF2F2).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);
    final iconBgColor = isWarning
        ? const Color(0xFFFEF2F2).withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.6);
    final hoverIconBgColor = isWarning
        ? const Color(0xFFFEE2E2)
        : AppColors.primary.withValues(alpha: 0.2);
    final defaultIconColor = isWarning
        ? widget.baseColor!
        : AppColors.navInactive;
    final titleColor = isWarning ? widget.baseColor! : AppColors.onSurface;
    final subtitleColor = isWarning
        ? widget.baseColor!.withValues(alpha: 0.6)
        : AppColors.onSurfaceVariant;
    final trailingColor = isWarning
        ? widget.baseColor!.withValues(alpha: 0.3)
        : AppColors.navInactive.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: _isHovered ? hoverBgColor : defaultBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (value) => setState(() {
                _isHovered = value;
              }),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isHovered ? hoverIconBgColor : iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: _isHovered ? mainColor : defaultIconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(widget.trailingIcon, color: trailingColor, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
