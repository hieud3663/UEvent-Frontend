// File: lib/features/ticketing/views/ticket_detail_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/widgets/glass_top_bar.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';
import 'package:frontend/features/ticketing/views/ticket_qr_sheet.dart';
import 'package:frontend/features/ticketing/widgets/ticket_info_row.dart';

/// Pushed screen: Upcoming ticket detail view.
/// Shows amber-glass hero, perforated ticket divider, info rows, and cancel button.
class TicketDetailView extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onBack;
  final VoidCallback? onCancelTap;

  const TicketDetailView({
    super.key,
    required this.ticket,
    this.onBack,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar spacing
                  const SizedBox(height: 80),

                  // Hero
                  _buildHero(),
                  const SizedBox(height: 8),

                  // Perforated divider
                  _buildPerforationDivider(),
                  const SizedBox(height: 8),

                  // Info section
                  _buildInfoSection(),

                  const SizedBox(height: 32),

                  // Button area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                    ),
                    child: Column(
                      children: [
                        // ── Show QR Code button (primary) ──
                        GestureDetector(
                          onTap: () => TicketQrSheet.show(context, ticket),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMd),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowPrimary,
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: AppColors.onPrimaryDark,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Show QR Code',
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    color: AppColors.onPrimaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ── Cancel Registration (outlined, destructive) ──
                        GestureDetector(
                          onTap: onCancelTap,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMd),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel Registration',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Changes available until 24h before event starts.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),

            // Fixed top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GlassTopBar(
                title: 'My Tickets',
                leadingIcon: Icons.arrow_back_ios_new,
                onLeadingTap: onBack ?? () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusCard),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSubtle,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background image
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                ticket.eventImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Dark gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Amber glass content panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: const Color(0xE6FFB800).withValues(alpha: 0.18),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.eventName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${ticket.date} · ${ticket.location}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Ticket code chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusFull),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            ticket.ticketCode,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Section / Row / Seat chips
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildMetaChip('Section', ticket.section),
                            if (ticket.row != null)
                              _buildMetaChip('Row', ticket.row!),
                            if (ticket.seat != null)
                              _buildMetaChip('Seat', ticket.seat!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerforationDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
      child: Row(
        children: [
          // Left notch
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
          // Dashed line
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 6.0;
                const dashSpace = 4.0;
                final count =
                    (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: dashWidth,
                      height: 1.5,
                      color: AppColors.outline,
                    ),
                  ),
                );
              },
            ),
          ),
          // Right notch
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePaddingH),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppConstants.radiusCard),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSubtle,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            TicketInfoRow(label: 'Date', value: ticket.date),
            TicketInfoRow(label: 'Time', value: ticket.timeRange),
            TicketInfoRow(label: 'Location', value: ticket.location),
            TicketInfoRow(label: 'Order ID', value: ticket.orderId),
            TicketInfoRow(label: 'Section', value: ticket.section),
            if (ticket.row != null)
              TicketInfoRow(label: 'Row', value: ticket.row!),
            if (ticket.seat != null)
              TicketInfoRow(
                label: 'Seat',
                value: ticket.seat!,
                showDivider: false,
              ),
          ],
        ),
      ),
    );
  }
}
