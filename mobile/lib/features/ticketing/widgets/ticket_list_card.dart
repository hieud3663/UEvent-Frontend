// File: lib/features/ticketing/widgets/ticket_list_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/ticketing/models/ticket_model.dart';

/// Glassmorphic card for an upcoming ticket in the list view.
class TicketListCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onTap;

  const TicketListCard({super.key, required this.ticket, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSubtle,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event thumbnail
            SizedBox(
              width: 100,
              height: 110,
              child: CachedNetworkImage(
                imageUrl: ticket.eventImageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 220,
                maxWidthDiskCache: 420,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.event,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      ticket.eventName,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Date chip
                    _buildInfoChip(Icons.calendar_today_outlined, ticket.date),
                    const SizedBox(height: 4),
                    // Location chip
                    _buildInfoChip(Icons.location_on_outlined, ticket.location),
                    const SizedBox(height: 8),
                    // Ticket code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      child: Text(
                        ticket.ticketCode,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onPrimaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chevron
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 14),
              child: Icon(Icons.chevron_right, color: AppColors.navInactive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
