class RegistrationFieldModel {
  final String id;
  final String fieldKey;
  final String label;
  final String fieldType;
  final bool isRequired;
  final bool isEditableAfterSubmit;
  final List<String> options;
  final int sortOrder;

  const RegistrationFieldModel({
    required this.id,
    required this.fieldKey,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    required this.isEditableAfterSubmit,
    required this.options,
    required this.sortOrder,
  });

  factory RegistrationFieldModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options_json'];

    return RegistrationFieldModel(
      id: json['id']?.toString() ?? '',
      fieldKey: json['field_key']?.toString() ?? json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fieldType: json['field_type']?.toString() ?? 'text',
      isRequired: json['is_required'] as bool? ?? false,
      isEditableAfterSubmit: json['is_editable_after_submit'] as bool? ?? false,
      options: rawOptions is List
          ? rawOptions.map((value) => value.toString()).toList()
          : const [],
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
