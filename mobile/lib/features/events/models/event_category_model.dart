class EventCategoryModel {
  final String id;
  final String name;
  final String? slug;

  const EventCategoryModel({required this.id, required this.name, this.slug});

  static const all = EventCategoryModel(id: '', name: 'All');

  String get queryValue => slug?.isNotEmpty == true ? slug! : name;

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name =
        json['name']?.toString() ??
        json['title']?.toString() ??
        json['label']?.toString() ??
        json['slug']?.toString() ??
        id;

    return EventCategoryModel(
      id: id,
      name: name,
      slug: json['slug']?.toString(),
    );
  }
}
