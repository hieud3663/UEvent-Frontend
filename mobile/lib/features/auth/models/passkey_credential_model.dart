class PasskeyCredentialModel {
  final String id;
  final String deviceName;
  final String deviceType;
  final bool backedUp;
  final List<String> transports;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  const PasskeyCredentialModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.backedUp,
    required this.transports,
    this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  factory PasskeyCredentialModel.fromJson(Map<String, dynamic> json) {
    return PasskeyCredentialModel(
      id: json['id']?.toString() ?? '',
      deviceName: json['device_name']?.toString() ?? '',
      deviceType: json['device_type']?.toString() ?? '',
      backedUp: json['backed_up'] == true,
      transports:
          (json['transports'] as List?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const [],
      createdAt: _dateTime(json['created_at']),
      lastUsedAt: _dateTime(json['last_used_at']),
      revokedAt: _dateTime(json['revoked_at']),
    );
  }

  String get displayName {
    final trimmed = deviceName.trim();
    return trimmed.isEmpty ? 'Thiết bị chưa đặt tên' : trimmed;
  }

  static DateTime? _dateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
