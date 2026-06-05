class AvatarUploadModel {
  final String objectKey;
  final String presignedUrl;
  final String method;
  final int expiresIn;

  const AvatarUploadModel({
    required this.objectKey,
    required this.presignedUrl,
    required this.method,
    required this.expiresIn,
  });

  factory AvatarUploadModel.fromJson(Map<String, dynamic> json) {
    return AvatarUploadModel(
      objectKey: json['object_key']?.toString() ?? '',
      presignedUrl:
          json['presigned_upload_url']?.toString() ??
          json['presigned_url']?.toString() ??
          '',
      method: json['method']?.toString() ?? 'PUT',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
    );
  }
}
