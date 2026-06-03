class EventShareLinkModel {
  final String eventId;
  final String slug;
  final String shareUrl;
  final String visibility;

  const EventShareLinkModel({
    required this.eventId,
    required this.slug,
    required this.shareUrl,
    required this.visibility,
  });

  factory EventShareLinkModel.fromJson(Map<String, dynamic> json) {
    return EventShareLinkModel(
      eventId: json['event_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shareUrl: json['share_url'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'public',
    );
  }
}
