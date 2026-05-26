import 'package:frontend/features/app_setting/models/app_setting_value_type.dart';

class AppSetting {
  final String key;
  final AppSettingValueType valueType;
  final Object? value;
  final DateTime updatedAt;

  const AppSetting({
    required this.key,
    required this.valueType,
    required this.value,
    required this.updatedAt,
  });

  factory AppSetting.fromRow(Map<String, Object?> row) {
    final valueType = AppSettingValueType.fromWireName(
      row['value_type'] as String? ?? AppSettingValueType.string.wireName,
    );
    final rawValue = row['value'] as String? ?? '';
    final updatedAt = row['updated_at'] as int? ?? 0;

    return AppSetting(
      key: row['key'] as String,
      valueType: valueType,
      value: valueType.decode(rawValue),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  Map<String, Object?> toRow() {
    return {
      'key': key,
      'value': valueType.encode(value),
      'value_type': valueType.wireName,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  AppSetting copyWith({
    String? key,
    AppSettingValueType? valueType,
    Object? value,
    DateTime? updatedAt,
  }) {
    return AppSetting(
      key: key ?? this.key,
      valueType: valueType ?? this.valueType,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
