// File: lib/features/user_events/views/registration_success_screen.dart
//
// Full-screen overlay shown after a successful registration.
// Push navigation with a blurred background.

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String eventName;
  final String ticketId;
  final VoidCallback? onViewTicket;
  final VoidCallback? onAddToWallet;

  static const _qrImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDkxVz6NjK7_cydZGXfAKvC_cd26VfMDQ_p2DkWHEkwRvzQ-aDPZoG6mKF5m_YOeHHoYqN2_D8kfhSTzzju3AQG4oza5Jo7cxhEkisN_v8OG5eEtqkwdDxNfXddAFqyzWCli5weaG4sCcTSif_jhAzI8P-TPPo4HR27XkYcjlB5GsGMqyPrls3h_YhFBLLZhWENMLYzUjl3rqcS9shZMzVpxeFMeslPwV2G09Ifc70VJsy-Bq64YmVjpnPXZRnVin3u2PdY4BP70Po';

  const RegistrationSuccessScreen({
    super.key,
    this.eventName = 'Tech Summit 2024',
    this.ticketId = '#UE-98210',
    this.onViewTicket,
    this.onAddToWallet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background placeholder
          Container(color: AppColors.background.withValues(alpha: 0.9)),
          // Semi-transparent overlay
          Container(color: Colors.black.withValues(alpha: 0.35)),
          // Modal card centred on screen
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 40,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 56,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Đăng ký thành công!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bạn đã sẵn sàng cho $eventName. Hẹn gặp bạn tại sự kiện!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Ticket card
                    _buildTicketCard(),
                    const SizedBox(height: 24),
                    // View ticket button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onViewTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Xem vé của tôi'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onAddToWallet,
                      child: Text(
                        'Thêm vào Apple Wallet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // QR code
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    _qrImageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.qr_code_2,
                        size: 64,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Dashed divider
                Row(
                  children: List.generate(
                    24,
                    (i) => Expanded(
                      child: Container(
                        height: 1,
                        color: i.isEven
                            ? AppColors.outline
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Ticket meta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SỰ KIỆN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            eventName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'MÃ VÉ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          ticketId,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
