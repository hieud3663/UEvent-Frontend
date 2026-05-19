import 'package:flutter/material.dart';

class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final Color? foregroundColor;
  final Widget? icon;
  final double iconGap;
  final double? height;

  const TextActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textStyle,
    this.foregroundColor,
    this.icon,
    this.iconGap = 8,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: iconGap)],
          Text(label, style: textStyle),
        ],
      ),
    );

    if (height == null) {
      return child;
    }

    return SizedBox(height: height, child: child);
  }
}
