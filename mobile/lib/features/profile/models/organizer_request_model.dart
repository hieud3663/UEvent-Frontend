class OrganizerRequestModel {
  final String id;
  final String status;
  final String reason;
  final String proofFileName;
  final String proofFileUrl;
  final String reviewNote;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  const OrganizerRequestModel({
    required this.id,
    required this.status,
    required this.reason,
    required this.proofFileName,
    required this.proofFileUrl,
    required this.reviewNote,
    this.reviewedAt,
    this.createdAt,
  });

  factory OrganizerRequestModel.fromJson(Map<String, dynamic> json) {
    return OrganizerRequestModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      reason: json['reason']?.toString() ?? '',
      proofFileName: json['proof_file_name']?.toString() ?? '',
      proofFileUrl: json['proof_file_url']?.toString() ?? '',
      reviewNote: json['review_note']?.toString() ?? '',
      reviewedAt: _dateTimeValue(json['reviewed_at']),
      createdAt: _dateTimeValue(json['created_at']),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    return switch (status) {
      'approved' => 'Đã duyệt',
      'rejected' => 'Đã từ chối',
      'cancelled' => 'Đã hủy',
      _ => 'Đang chờ duyệt',
    };
  }
}

DateTime? _dateTimeValue(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
