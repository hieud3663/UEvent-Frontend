import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class DiscoveryProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? avatarCacheKey;
  final String? displayName;

  const DiscoveryProfileAvatar({
    super.key,
    this.avatarUrl,
    this.avatarCacheKey,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = avatarUrl?.trim() ?? '';

    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: normalizedUrl.isEmpty
            ? _AvatarFallback(label: _initials)
            : CachedNetworkImage(
                imageUrl: normalizedUrl,
                cacheKey: avatarCacheKey,
                fit: BoxFit.cover,
                memCacheWidth: 96,
                maxWidthDiskCache: 192,
                errorWidget: (_, _, _) => _AvatarFallback(label: _initials),
              ),
      ),
    );
  }

  String get _initials {
    final name = displayName?.trim() ?? '';
    if (name.isEmpty) return 'U';

    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.take(2).map((part) => part.characters.first);
    final value = letters.join().toUpperCase();
    return value.isEmpty ? 'U' : value;
  }
}

class _AvatarFallback extends StatelessWidget {
  final String label;

  const _AvatarFallback({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
