import 'package:flutter/material.dart';

class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final Color? foregroundColor;
  final Widget? icon;
  final double iconGap;
  final double? height;
  final bool isLoading;

  const TextActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textStyle,
    this.foregroundColor,
    this.icon,
    this.iconGap = 8,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor =
        foregroundColor ?? Theme.of(context).colorScheme.primary;
    final child = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveForegroundColor,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  effectiveForegroundColor,
                ),
              ),
            ),
            SizedBox(width: iconGap),
          ] else if (icon != null) ...[
            icon!,
            SizedBox(width: iconGap),
          ],
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
