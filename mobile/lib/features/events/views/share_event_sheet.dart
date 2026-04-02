// File: lib/features/events/views/share_event_sheet.dart
//
// Share Event bottom sheet — glass frosted modal.
// Present via showModalBottomSheet.

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/features/events/widgets/share_action_grid.dart';
import 'package:frontend/features/events/widgets/share_social_row.dart';

class ShareEventSheet extends StatelessWidget {
  final String eventName;
  final String eventLink;
  final String eventImageUrl;
  final VoidCallback? onClose;

  static const _contactAvatars = [
    ('Marcus', 'https://lh3.googleusercontent.com/aida-public/AB6AXuByrHsHJAc598bKIFz7IkGNp961jJqLHL99HcsYjUYvlXtj1mmZCks6M9TyEEnepnMEVC6KbrcBIgVYVq2ZW_QOxYSWiFYVMyIZYLMg2H0AM1QT1bEIgCvSl8JSXRJB2ExcH9FPkTDEAnndaYMI0OPTQYjk6V-sBD2IPBLpWVtmt0RumOSdwbzdEn1PVWBL_FCZ8lX4buVQde46hZZtWLl1XSrUq9XKJETGSbmWs09HjMeglGskdiPnOh1R0BQe0lVOwHT0Gu1T_es', true),
    ('Sarah', 'https://lh3.googleusercontent.com/aida-public/AB6AXuC_Jf24_ui8CVSfWeKpma_X7JLYgAzbhq8rFqsxrzdl1PKJFWQ7rYcLMKS2DuaHTIB5TSLzx_YgUmOXHm-MQjHE9--AArjfyVTqEzAH4YHNYHZ1HLA_JHzj6DKdbYbpaOTHJGVlrBRdZGnTPGhTKBOM-qB2NjMpRlXebZRF-fCAxRNVWXe-4KYnoiBW2PgvDVOfqUfkxnuXRiLsZDhYdaE8FnLDJRqRCvvxt5kWc-LrXAkydwhH6z80h1IVqAO9tvcoylER4Fzky58', false),
    ('Alex', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDjphqDT41Ruh7iVBPu70odSneMSu85eFvpIEzpmW5li1CRY23mK39rpVstHeAIa83jpnLSwg9nCeiwRvqfnYNk3nR03F1YsUQYQBVlPnMf4pVI0WV3Z0TMhQt9T6lpiYkdXbumRg2SHG4LrcNXStRVDjiALVzWG9QNG-YhFzgw3MgX3crO2HyDFnw-iHriDNJCV0mtjK-Fb33HnPIQigS6vIzS4dYGlWYx_5-Y7DvU-x_bkRzHcYigaBL-FbWP4s_5BxTnTUoRfkU', false),
    ('Elena', 'https://lh3.googleusercontent.com/aida-public/AB6AXuA894Z7Wu-ur7mTA05UqUneeX6nawJf6SO7mokkWBhTcgrO0gxev3ZMS5YA3HxzFhgeb4ds1RR-r72GigyAISR_Tad5yrLGtsbJiferSe41XgG7H11t7cXy3riJy-CrHT19jNs-W19TAoJeVYEWFxPcT60kJOFMY3i_DrVZoL4hq9pdAWT1fgms-0K74ZX4KmhKqVpz-iw8v0IALFUOe0bT5KDm-IOBd9TGkqal4iuKGQ52gADOJ-NxYJWOGQEIRjS1PPoH1PJYZAk', false),
  ];

  const ShareEventSheet({
    super.key,
    this.eventName = 'Summer Solstice Festival',
    this.eventLink = 'https://uevents.app/summer24',
    this.eventImageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAtsijSJ3J1RBnyNkXwEA4Zl_6ct8vcvlOsUU9s_0-_cxOFwOtyLAimNeGmBXnglU2Vxx39L9NrCMqFNnwtq0rZpCkYpYth7QHsINWF33RfuivCKTdiP9pBS1RbRuJ9ybbTuWXw3vcyQhOTsIB9CYnPElvDEKJMDsR8VZp_bljGh_a8SzfGl1OyKgpc8uK2TSrhvJ57pU-J_Bk0knkomqFfqa3iYdSjqjxSD1NcMpIpsyXI9xZUZeZpFfVrmCl3qNKkTeKesX3o8rs',
    this.onClose,
  });

  /// Convenience: show as modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    String eventName = 'Summer Solstice Festival',
    String eventLink = 'https://uevents.app/summer24',
    String? eventImageUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (_) => ShareEventSheet(
        eventName: eventName,
        eventLink: eventLink,
        eventImageUrl: eventImageUrl ??
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAtsijSJ3J1RBnyNkXwEA4Zl_6ct8vcvlOsUU9s_0-_cxOFwOtyLAimNeGmBXnglU2Vxx39L9NrCMqFNnwtq0rZpCkYpYth7QHsINWF33RfuivCKTdiP9pBS1RbRuJ9ybbTuWXw3vcyQhOTsIB9CYnPElvDEKJMDsR8VZp_bljGh_a8SzfGl1OyKgpc8uK2TSrhvJ57pU-J_Bk0knkomqFfqa3iYdSjqjxSD1NcMpIpsyXI9xZUZeZpFfVrmCl3qNKkTeKesX3o8rs',
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: event thumbnail + name + link + close
                  _buildHeader(context),
                  const SizedBox(height: 28),
                  // Action grid
                  ShareActionGrid(
                    onCopyLink: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied!')),
                      );
                    },
                    onQrCode: () {},
                    onSavePost: () {},
                    onMore: () {},
                  ),
                  const SizedBox(height: 28),
                  // Social row
                  Text(
                    'SEND TO FRIENDS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: const ShareSocialRow(),
                  ),
                  const SizedBox(height: 24),
                  // Recent contacts
                  Text(
                    'RECENT CONTACTS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _contactAvatars.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 20),
                      itemBuilder: (_, i) {
                        final (name, url, isActive) = _contactAvatars[i];
                        return _ContactItem(
                          name: name,
                          imageUrl: url,
                          isSelected: isActive,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Event thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              eventImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.surfaceVariant),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                eventLink,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onClose ?? () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isSelected;

  const _ContactItem({
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariant),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
