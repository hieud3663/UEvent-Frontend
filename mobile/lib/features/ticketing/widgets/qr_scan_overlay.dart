// File: lib/features/ticketing/widgets/qr_scan_overlay.dart

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

/// Animated QR scan frame overlay.
/// Renders 4 golden corner brackets and a vertical scan line that
/// animates up and down. Below the frame shows a hint label.
class QrScanOverlay extends StatefulWidget {
  final double frameSize;

  const QrScanOverlay({
    super.key,
    this.frameSize = 240.0,
  });

  @override
  State<QrScanOverlay> createState() => _QrScanOverlayState();
}

class _QrScanOverlayState extends State<QrScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.frameSize;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Dim overlay with transparent center
              CustomPaint(
                size: Size(size, size),
                painter: _CornerBracketPainter(),
              ),

              // Animated scan line
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (_, __) {
                  return Positioned(
                    left: 12,
                    right: 12,
                    top: 12 + (_scanAnimation.value * (size - 24)),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary.withValues(alpha: 0.9),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Hint label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Align ticket QR code within the frame',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Draws 4 corner brackets (L-shaped golden lines) at each corner.
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = AppColors.primary;
    const strokeW = 3.5;
    const cornerLen = 32.0;
    const radius = 6.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(radius, cornerLen)
        ..lineTo(radius, radius)
        ..lineTo(cornerLen, radius),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, radius)
        ..lineTo(size.width - radius, radius)
        ..lineTo(size.width - radius, cornerLen),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(radius, size.height - cornerLen)
        ..lineTo(radius, size.height - radius)
        ..lineTo(cornerLen, size.height - radius),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, size.height - radius)
        ..lineTo(size.width - radius, size.height - radius)
        ..lineTo(size.width - radius, size.height - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
