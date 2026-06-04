class OrganizerNotificationAudienceOption {
  final String value;
  final String label;

  const OrganizerNotificationAudienceOption({
    required this.value,
    required this.label,
  });
}

const organizerNotificationAudienceOptions = [
  OrganizerNotificationAudienceOption(value: 'registered', label: 'Đã đăng ký'),
  OrganizerNotificationAudienceOption(
    value: 'checked_in',
    label: 'Đã check-in',
  ),
  OrganizerNotificationAudienceOption(
    value: 'waitlisted',
    label: 'Danh sách chờ',
  ),
  OrganizerNotificationAudienceOption(value: 'active', label: 'Đang tham gia'),
  OrganizerNotificationAudienceOption(
    value: 'all_participants',
    label: 'Tất cả',
  ),
];
