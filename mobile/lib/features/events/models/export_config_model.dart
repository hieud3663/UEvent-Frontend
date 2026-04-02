// File: lib/features/events/models/export_config_model.dart

enum ExportFormat { csv, pdf }

class ExportConfigModel {
  final ExportFormat format;
  final bool includeName;
  final bool includeId;
  final bool includeEmail;
  final bool includeStatus;

  const ExportConfigModel({
    required this.format,
    required this.includeName,
    required this.includeId,
    required this.includeEmail,
    required this.includeStatus,
  });

  ExportConfigModel copyWith({
    ExportFormat? format,
    bool? includeName,
    bool? includeId,
    bool? includeEmail,
    bool? includeStatus,
  }) {
    return ExportConfigModel(
      format: format ?? this.format,
      includeName: includeName ?? this.includeName,
      includeId: includeId ?? this.includeId,
      includeEmail: includeEmail ?? this.includeEmail,
      includeStatus: includeStatus ?? this.includeStatus,
    );
  }

  /// Initial default state matching the design
  factory ExportConfigModel.initial() {
    return const ExportConfigModel(
      format: ExportFormat.csv,
      includeName: true,
      includeId: true,
      includeEmail: true,
      includeStatus: false,
    );
  }

  bool get isAllSelected =>
      includeName && includeId && includeEmail && includeStatus;

  ExportConfigModel selectAll() {
    return copyWith(
      includeName: true,
      includeId: true,
      includeEmail: true,
      includeStatus: true,
    );
  }
}
