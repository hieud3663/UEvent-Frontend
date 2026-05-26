enum NotificationCategory {
  ticket,
  organizer,
  marketing,
  event,
  unknown;

  static NotificationCategory fromPayload(Map<String, dynamic> data) {
    final rawType =
        (data['type'] ?? data['notification_type'] ?? data['category'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

    return switch (rawType) {
      'ticket' || 'ticket_update' || 'ticket_updates' => ticket,
      'organizer' || 'organizer_update' || 'organizer_updates' => organizer,
      'marketing' || 'promotion' || 'promotional' => marketing,
      'event' || 'event_reminder' || 'reminder' => event,
      _ when rawType.contains('ticket') => ticket,
      _ when rawType.contains('organizer') => organizer,
      _ when rawType.contains('marketing') || rawType.contains('promotion') =>
        marketing,
      _ when rawType.contains('event') || rawType.contains('reminder') => event,
      _ => unknown,
    };
  }
}
