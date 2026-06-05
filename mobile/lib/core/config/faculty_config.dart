class FacultyConfig {
  static const List<String> values = [
    'Công nghệ thông tin',
    'Kinh tế',
    'Ngoại ngữ',
    'Luật',
    'Xây dựng',
    'Điện - Điện tử',
    'Cơ khí',
    'Mỹ thuật công nghiệp',
    'Môi trường & Tài nguyên',
    'Khoa học ứng dụng',
  ];

  static String? normalize(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    if (values.contains(normalized)) return normalized;

    return switch (normalized.toLowerCase()) {
      'cntt' => 'Công nghệ thông tin',
      'kt' => 'Kinh tế',
      'nn' => 'Ngoại ngữ',
      'luat' => 'Luật',
      'xd' => 'Xây dựng',
      'dien' => 'Điện - Điện tử',
      'co-khi' => 'Cơ khí',
      'mt' => 'Mỹ thuật công nghiệp',
      'moi-truong' => 'Môi trường & Tài nguyên',
      'khoa-hoc' => 'Khoa học ứng dụng',
      _ => normalized,
    };
  }
}
