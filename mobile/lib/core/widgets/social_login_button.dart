import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconPath,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          backgroundColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: 0.6),
          ),
          overlayColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.04),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 20);
              },
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
