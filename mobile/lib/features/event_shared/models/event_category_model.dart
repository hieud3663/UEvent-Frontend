class EventCategoryModel {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? color;
  final String? icon;

  const EventCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.color,
    this.icon,
  });

  static const all = EventCategoryModel(id: '', name: 'All');

  String get queryValue => slug?.isNotEmpty == true ? slug! : name;

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';

    return EventCategoryModel(
      id: id,
      name: name,
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}
