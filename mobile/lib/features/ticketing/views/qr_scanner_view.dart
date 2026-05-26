import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_icon_button.dart';
import 'package:frontend/core/widgets/glass_input_field.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/organizer_events/controller/organizer_event_controller.dart';
import 'package:frontend/features/organizer_events/models/check_in_model.dart';
import 'package:frontend/features/ticketing/widgets/qr_scan_overlay.dart';
import 'package:frontend/features/ticketing/views/qr_scan_result_sheet.dart';

class QrScannerView extends ConsumerStatefulWidget {
  final String eventId;
  final VoidCallback onBack;

  const QrScannerView({super.key, required this.eventId, required this.onBack});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends ConsumerState<QrScannerView> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final TextEditingController _emailController = TextEditingController();

  bool _isProcessing = false;
  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _emailController.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessing || _isSheetOpen) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final parsed = _parseQr(rawValue);
    if (parsed == null) {
      await _showResult(const CheckInResultModel(result: 'invalid_format'));
      return;
    }

    await _submitCheckIn(
      qrPayload: parsed.qrPayload,
      qrSignature: parsed.qrSignature,
      note: 'QR scan',
    );
  }

  _ParsedQr? _parseQr(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) return null;

      final qrPayload = decoded['qr_payload']?.toString() ?? '';
      final qrSignature = decoded['qr_signature']?.toString() ?? '';
      if (qrPayload.isEmpty || qrSignature.isEmpty) return null;

      return _ParsedQr(qrPayload: qrPayload, qrSignature: qrSignature);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitCheckIn({
    String? qrPayload,
    String? qrSignature,
    String? email,
    String? note,
  }) async {
    if (_isProcessing || _isSheetOpen) return;
    setState(() => _isProcessing = true);

    final result = await ref
        .read(organizerEventRegistrationControllerProvider.notifier)
        .checkInRegistration(
          eventId: widget.eventId,
          qrPayload: qrPayload,
          qrSignature: qrSignature,
          email: email,
          note: note,
        );

    if (!mounted) return;
    setState(() => _isProcessing = false);
    await _showResult(
      result ?? const CheckInResultModel(result: 'invalid_ticket'),
    );
  }

  Future<void> _showResult(CheckInResultModel result) async {
    if (_isSheetOpen || !mounted) return;
    _isSheetOpen = true;
    unawaited(_scannerController.stop());

    await QrScanResultSheet.show(
      context,
      isSuccess: result.result == 'success',
      title: _resultTitle(result.result),
      description: _resultDescription(result.result),
      attendeeName: result.registration?.user?.displayName,
      attendeeId: result.registration?.user?.email,
      onScanNext: _closeSheetAndResume,
      onTryAgain: _closeSheetAndResume,
      onCancel: _closeSheetAndResume,
    );
  }

  void _closeSheetAndResume() {
    Navigator.of(context).pop();
    _isSheetOpen = false;
    if (mounted) {
      unawaited(_scannerController.start());
    }
  }

  Future<void> _showManualEmailDialog() async {
    _emailController.clear();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Check-in thủ công'),
          content: GlassInputField(
            label: 'Email',
            placeholder: 'attendee@example.com',
            leadingIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          actions: [
            SecondaryButton(
              label: 'Hủy',
              isFullWidth: false,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            PrimaryButton(
              label: 'Check-in',
              isFullWidth: false,
              onPressed: () {
                Navigator.of(dialogContext).pop(_emailController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (email == null || email.isEmpty) return;
    await _submitCheckIn(email: email, note: 'Manual email');
  }

  String _resultTitle(String result) {
    return switch (result) {
      'success' => 'Check-in thành công',
      'already_checked_in' => 'Vé đã check-in',
      'invalid_format' => 'QR sai định dạng',
      'event_unavailable' => 'Sự kiện chưa thể check-in',
      _ => 'Vé không hợp lệ',
    };
  }

  String _resultDescription(String result) {
    return switch (result) {
      'success' => 'Người tham dự đã được ghi nhận vào sự kiện.',
      'already_checked_in' => 'Vé này đã được check-in trước đó.',
      'invalid_format' => 'QR thiếu payload hoặc signature hợp lệ.',
      'event_unavailable' =>
        'Event chưa bắt đầu, đã kết thúc, hoặc chưa cho phép check-in.',
      _ => 'QR hết hạn, vé không hợp lệ, hoặc không tìm thấy ticket.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            width: screenW,
            height: screenH,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _handleDetect,
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: const QrScanOverlay(frameSize: 260),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          Positioned(
            left: AppConstants.pagePaddingH,
            right: AppConstants.pagePaddingH,
            bottom: 48,
            child: SecondaryButton(
              label: 'Nhập email thủ công',
              onPressed: _isProcessing ? null : _showManualEmailDialog,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
                vertical: 8,
              ),
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back,
                    iconColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 12),
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
                  GlassIconButton(
                    icon: Icons.flash_on_rounded,
                    iconColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    onPressed: () =>
                        unawaited(_scannerController.toggleTorch()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsedQr {
  final String qrPayload;
  final String qrSignature;

  const _ParsedQr({required this.qrPayload, required this.qrSignature});
}
