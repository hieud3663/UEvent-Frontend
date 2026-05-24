class EventCoverUploadModel {
  final String objectKey;
  final String presignedUrl;
  final String method;
  final int expiresIn;

  const EventCoverUploadModel({
    required this.objectKey,
    required this.presignedUrl,
    required this.method,
    required this.expiresIn,
  });

  factory EventCoverUploadModel.fromJson(Map<String, dynamic> json) {
    return EventCoverUploadModel(
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
