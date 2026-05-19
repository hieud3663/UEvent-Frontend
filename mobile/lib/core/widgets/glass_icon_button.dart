import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = const Color(0x80FFFFFF),
    this.iconColor = AppColors.onSurface,
    this.size = 40,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkResponse(
        onTap: onPressed,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        radius: size / 2,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
