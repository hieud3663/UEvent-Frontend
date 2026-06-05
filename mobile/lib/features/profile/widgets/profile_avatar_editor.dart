import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';

class ProfileAvatarEditor extends StatelessWidget {
  final String? avatarUrl;
  final String? avatarCacheKey;
  final File? previewFile;
  final bool isLoading;
  final VoidCallback? onTap;

  const ProfileAvatarEditor({
    super.key,
    required this.avatarUrl,
    this.avatarCacheKey,
    required this.previewFile,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.outlineVariant,
                  child: ClipOval(
                    child: _AvatarImage(
                      previewFile: previewFile,
                      avatarUrl: avatarUrl,
                      avatarCacheKey: avatarCacheKey,
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.onPrimaryContainer,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: isLoading ? null : onTap,
          icon: const Icon(Icons.image_outlined, size: 18),
          label: Text(
            previewFile == null ? 'Đổi ảnh đại diện' : 'Chọn ảnh khác',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final File? previewFile;
  final String? avatarUrl;
  final String? avatarCacheKey;

  const _AvatarImage({
    required this.previewFile,
    required this.avatarUrl,
    required this.avatarCacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final file = previewFile;
    if (file != null) {
      return Image.file(file, fit: BoxFit.cover);
    }

    final normalizedUrl = avatarUrl?.trim() ?? '';
    if (normalizedUrl.isEmpty) {
      return const Icon(Icons.person, size: 64, color: Colors.white);
    }

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      cacheKey: avatarCacheKey,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) =>
          const Icon(Icons.person, size: 64, color: Colors.white),
    );
  }
}
