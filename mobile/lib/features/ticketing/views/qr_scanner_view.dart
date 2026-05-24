// File: lib/features/ticketing/views/qr_scanner_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/ticketing/widgets/qr_scan_overlay.dart';
import 'package:frontend/features/ticketing/widgets/qr_stats_row.dart';
import 'package:frontend/features/ticketing/views/qr_scan_result_sheet.dart';

/// Full-screen QR check-in scanner screen.
/// Push navigation (no bottom nav). Dark gradient background simulates camera.
///
/// For demo purposes, each tap on the scan area toggles between
/// the Success and Error result states.
class QrScannerView extends StatefulWidget {
  final VoidCallback onBack;

  const QrScannerView({super.key, required this.onBack});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  // Demo state: toggle between success and error on each scan
  bool _nextResultIsSuccess = true;
  bool _isSheetOpen = false;

  // Mock stats
  int _checkedIn = 142;
  final int _remaining = 58;

  @override
  void initState() {
    super.initState();
    // Use dark status bar icons on the dark background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    // Restore light status bar icons when leaving
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }

  void _simulateScan() {
    if (_isSheetOpen) return;
    _isSheetOpen = true;
    final isSuccess = _nextResultIsSuccess;

    QrScanResultSheet.show(
      context,
      isSuccess: isSuccess,
      attendeeName: 'Nguyễn Văn A',
      attendeeId: '21520000',
      onScanNext: () {
        Navigator.of(context).pop();
        _isSheetOpen = false;
        setState(() {
          _nextResultIsSuccess = !_nextResultIsSuccess;
          if (isSuccess) _checkedIn++;
        });
      },
      onTryAgain: () {
        Navigator.of(context).pop();
        _isSheetOpen = false;
        setState(() => _nextResultIsSuccess = !_nextResultIsSuccess);
      },
      onCancel: () {
        Navigator.of(context).pop();
        _isSheetOpen = false;
        setState(() => _nextResultIsSuccess = !_nextResultIsSuccess);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Dark camera background ──────────────────────────────────────
          Container(
            width: screenW,
            height: screenH,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF3A3A3A),
                  Color(0xFF2D2D2D),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Tappable scan area ────────────────────────────────────────
          GestureDetector(
            onTap: _simulateScan,
            behavior: HitTestBehavior.translucent,
            child: SizedBox(width: screenW, height: screenH),
          ),

          // ── Scan overlay centred in screen ─────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: const QrScanOverlay(frameSize: 260),
            ),
          ),

          // ── Stats row, near the bottom ─────────────────────────────────
          Positioned(
            left: AppConstants.pagePaddingHLarge,
            right: AppConstants.pagePaddingHLarge,
            bottom: 110,
            child: QrStatsRow(checkedIn: _checkedIn, remaining: _remaining),
          ),

          // ── Manual entry button ────────────────────────────────────────
          Positioned(
            left: AppConstants.pagePaddingH,
            right: AppConstants.pagePaddingH,
            bottom: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.keyboard_outlined, size: 18),
              label: const Text(
                'Nhập mã vé thủ công',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ── Top Bar ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // Back button
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 12),

                  // Title block
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Check-in Scanner',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'UEVENTS BTC',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flash / refresh icon
                  _CircleIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: () => setState(() {}),
                  ),
                ],
              ),
            ),
          ),

          // ── Yellow star icon (decorative, top-right of bar) ────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 60, top: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.star, color: AppColors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted-glass-style circular icon button for the dark top bar.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
