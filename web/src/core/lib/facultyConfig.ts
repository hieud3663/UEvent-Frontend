export const facultyValues = [
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
] as const;

export const facultyOptions = facultyValues.map((value) => ({
  value,
  label: value,
}));

export function normalizeFaculty(value?: string | null): string | null {
  const normalized = value?.trim();
  if (!normalized) return null;

  if (facultyValues.includes(normalized as (typeof facultyValues)[number])) {
    return normalized;
  }

  switch (normalized.toLowerCase()) {
    case 'cntt':
      return 'Công nghệ thông tin';
    case 'kt':
      return 'Kinh tế';
    case 'nn':
      return 'Ngoại ngữ';
    case 'luat':
      return 'Luật';
    case 'xd':
      return 'Xây dựng';
    case 'dien':
      return 'Điện - Điện tử';
    case 'co-khi':
      return 'Cơ khí';
    case 'mt':
      return 'Mỹ thuật công nghiệp';
    case 'moi-truong':
      return 'Môi trường & Tài nguyên';
    case 'khoa-hoc':
      return 'Khoa học ứng dụng';
    default:
      return normalized;
  }
}
