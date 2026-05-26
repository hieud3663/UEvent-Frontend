import 'dart:convert';

enum AppSettingValueType {
  boolean('bool'),
  integer('int'),
  decimal('double'),
  string('string'),
  json('json');

  const AppSettingValueType(this.wireName);

  final String wireName;

  static AppSettingValueType fromWireName(String value) {
    return AppSettingValueType.values.firstWhere(
      (type) => type.wireName == value,
      orElse: () => AppSettingValueType.string,
    );
  }

  String encode(Object? value) {
    return switch (this) {
      AppSettingValueType.boolean => value == true ? 'true' : 'false',
      AppSettingValueType.integer => '${(value as num?)?.round() ?? 0}',
      AppSettingValueType.decimal => '${(value as num?)?.toDouble() ?? 0}',
      AppSettingValueType.string => value?.toString() ?? '',
      AppSettingValueType.json => jsonEncode(value),
    };
  }

  Object? decode(String value) {
    return switch (this) {
      AppSettingValueType.boolean => value == 'true',
      AppSettingValueType.integer => int.tryParse(value) ?? 0,
      AppSettingValueType.decimal => double.tryParse(value) ?? 0,
      AppSettingValueType.string => value,
      AppSettingValueType.json => _decodeJson(value),
    };
  }

  Object _decodeJson(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic> || decoded is List<dynamic>) {
        return decoded;
      }
    } on FormatException {
      return const <String, Object?>{};
    }

    return const <String, Object?>{};
  }
}
