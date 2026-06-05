String? stableImageCacheKey({
  required String imageUrl,
  String? explicitCacheKey,
}) {
  final normalizedKey = explicitCacheKey?.trim();
  if (normalizedKey != null && normalizedKey.isNotEmpty) {
    return normalizedKey;
  }

  final normalizedUrl = imageUrl.trim();
  if (normalizedUrl.isEmpty) return null;

  final uri = Uri.tryParse(normalizedUrl);
  if (uri == null || !uri.hasScheme || !_isPresignedS3Url(uri)) {
    return null;
  }

  return 'presigned-s3:${uri.replace(query: '', fragment: '')}';
}

bool _isPresignedS3Url(Uri uri) {
  final queryKeys = uri.queryParameters.keys.map((key) => key.toLowerCase());
  return queryKeys.any(
    (key) =>
        key == 'x-amz-signature' ||
        key == 'x-amz-credential' ||
        key == 'x-amz-algorithm',
  );
}
