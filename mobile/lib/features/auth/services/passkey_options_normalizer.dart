class PasskeyOptionsNormalizer {
  const PasskeyOptionsNormalizer._();

  static Map<String, dynamic> normalize(Map<String, dynamic> options) {
    return <String, dynamic>{
      ...options,
      if (options['allowCredentials'] is List)
        'allowCredentials': _normalizeCredentials(options['allowCredentials']),
      if (options['excludeCredentials'] is List)
        'excludeCredentials': _normalizeCredentials(
          options['excludeCredentials'],
        ),
    };
  }

  static List<Object?> _normalizeCredentials(Object? value) {
    final credentials = value;
    if (credentials is! List) return const [];

    return credentials
        .map((credential) {
          if (credential is! Map) return credential;
          return <String, dynamic>{
            ...credential.cast<String, dynamic>(),
            if (credential['transports'] is! List)
              'transports': const <String>[],
          };
        })
        .toList(growable: false);
  }
}
