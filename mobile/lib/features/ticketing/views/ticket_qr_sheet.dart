import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';

/// Bottom sheet displaying the QR code for a ticket.
class TicketQrSheet extends ConsumerStatefulWidget {
  final TicketModel ticket;

  const TicketQrSheet({super.key, required this.ticket});

  static Future<void> show(BuildContext context, TicketModel ticket) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TicketQrSheet(ticket: ticket),
    );
  }

  @override
  ConsumerState<TicketQrSheet> createState() => _TicketQrSheetState();
}

class _TicketQrSheetState extends ConsumerState<TicketQrSheet> {
  Timer? _refreshTimer;
  TicketQrTokenModel? _token;
  Object? _error;
  bool _isLoading = false;
  bool _isStopped = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final eventId = widget.ticket.eventId;
    if (eventId.isEmpty) {
      setState(() {
        _error = 'Không tìm thấy sự kiện để tạo QR.';
        _isStopped = true;
      });
      return;
    }

    if (widget.ticket.isCheckedIn) {
      setState(() {
        _error = 'Vé đã được check-in.';
        _isStopped = true;
      });
      return;
    }

    if (widget.ticket.status == TicketStatus.cancelled) {
      setState(() {
        _error = 'Vé không còn hợp lệ để tạo QR.';
        _isStopped = true;
      });
      return;
    }

    setState(() {
      _isLoading = _token == null;
      _error = null;
    });

    try {
      final nextToken = await ref
          .read(ticketingServiceProvider)
          .getEventTicketToken(eventId);
      if (!mounted) return;

      setState(() {
        _token = nextToken;
        _isLoading = false;
        _isStopped = !nextToken.hasSignedPayload;
      });

      if (nextToken.hasSignedPayload) {
        _scheduleRefresh(nextToken);
      }
    } on DioException catch (error) {
      if (!mounted) return;
      _refreshTimer?.cancel();
      setState(() {
        _error = _token == null
            ? error
            : 'Vé không còn hợp lệ. Vui lòng tải lại chi tiết vé.';
        _isLoading = false;
        _isStopped = true;
      });
    } catch (error) {
      if (!mounted) return;
      _refreshTimer?.cancel();
      setState(() {
        _error = error;
        _isLoading = false;
        _isStopped = true;
      });
    }
  }

  void _scheduleRefresh(TicketQrTokenModel token) {
    _refreshTimer?.cancel();

    final now = DateTime.now();
    final validTo = token.validTo?.toLocal();
    final duration = validTo == null
        ? const Duration(seconds: 11)
        : validTo.difference(now) - const Duration(seconds: 3);
    final safeDuration = duration < const Duration(seconds: 2)
        ? const Duration(seconds: 2)
        : duration;

    _refreshTimer = Timer(safeDuration, () {
      if (mounted && !_isStopped) {
        unawaited(_loadToken());
      }
    });
  }

  String? get _qrData {
    final token = _token;
    if (token == null || !token.hasSignedPayload) return null;
    return jsonEncode(token.toQrContentJson());
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _qrData;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text('Mã QR vé của bạn', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            widget.ticket.eventName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 28),

          // QR Code card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: AppColors.outlineVariant, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSubtle,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (qrData != null)
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0F172A),
                    ),
                    embeddedImage: null,
                  )
                else
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Center(
                      child: Text(
                        'Không tạo được mã QR.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Ticket code below QR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                  child: Text(
                    _token?.ticketCode.isNotEmpty == true
                        ? _token!.ticketCode
                        : widget.ticket.ticketCode,
                    style: AppTextStyles.titleSmall.copyWith(
                      letterSpacing: 2,
                      color: AppColors.onPrimaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.navInactive),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _error == null
                      ? 'Mã QR tự làm mới trong thời gian ngắn.'
                      : _error.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _error == null
                        ? AppColors.navInactive
                        : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Close button
          SecondaryButton(
            label: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
