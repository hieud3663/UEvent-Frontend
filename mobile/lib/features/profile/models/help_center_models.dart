class HelpCenterArticleModel {
  final String id;
  final String categorySlug;
  final String title;
  final String slug;
  final String summary;
  final String body;
  final String locale;
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  const HelpCenterArticleModel({
    required this.id,
    required this.categorySlug,
    required this.title,
    required this.slug,
    required this.summary,
    required this.body,
    required this.locale,
    this.publishedAt,
    this.updatedAt,
  });

  factory HelpCenterArticleModel.fromJson(Map<String, dynamic> json) {
    return HelpCenterArticleModel(
      id: json['id']?.toString() ?? '',
      categorySlug: json['category_slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      locale: json['locale']?.toString() ?? 'vi',
      publishedAt: _dateTime(json['published_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return title.toLowerCase().contains(normalized) ||
        summary.toLowerCase().contains(normalized) ||
        body.toLowerCase().contains(normalized);
  }

  static DateTime? _dateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class HelpCenterCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;
  final List<HelpCenterArticleModel> articles;

  const HelpCenterCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.sortOrder,
    required this.articles,
  });

  factory HelpCenterCategoryModel.fromJson(Map<String, dynamic> json) {
    return HelpCenterCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sortOrder: json['sort_order'] is int ? json['sort_order'] as int : 0,
      articles:
          (json['articles'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(HelpCenterArticleModel.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }

  HelpCenterCategoryModel filter(String query) {
    return HelpCenterCategoryModel(
      id: id,
      name: name,
      slug: slug,
      description: description,
      sortOrder: sortOrder,
      articles: articles.where((article) => article.matches(query)).toList(),
    );
  }
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final List<SupportMessageModel> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.messages,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      messages:
          (json['messages'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(SupportMessageModel.fromJson)
              .toList(growable: false) ??
          const [],
      createdAt: HelpCenterArticleModel._dateTime(json['created_at']),
      updatedAt: HelpCenterArticleModel._dateTime(json['updated_at']),
    );
  }

  String get statusLabel {
    return switch (status) {
      'open' => 'Đang mở',
      'in_progress' => 'Đang xử lý',
      'resolved' => 'Đã xử lý',
      'closed' => 'Đã đóng',
      _ => status,
    };
  }

  bool get canReply {
    return status == 'open' || status == 'in_progress';
  }
}

class SupportMessageModel {
  final String id;
  final String content;
  final bool isStaff;
  final String authorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupportMessageModel({
    required this.id,
    required this.content,
    required this.isStaff,
    required this.authorName,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isStaff: json['is_staff'] == true,
      authorName: json['author_name']?.toString() ?? '',
      createdAt: HelpCenterArticleModel._dateTime(json['created_at']),
      updatedAt: HelpCenterArticleModel._dateTime(json['updated_at']),
    );
  }
}

class LegalDocumentModel {
  final String id;
  final String documentType;
  final String title;
  final String version;
  final String summary;
  final String body;
  final String locale;
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  const LegalDocumentModel({
    required this.id,
    required this.documentType,
    required this.title,
    required this.version,
    required this.summary,
    required this.body,
    required this.locale,
    this.publishedAt,
    this.updatedAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      locale: json['locale']?.toString() ?? 'vi',
      publishedAt: HelpCenterArticleModel._dateTime(json['published_at']),
      updatedAt: HelpCenterArticleModel._dateTime(json['updated_at']),
    );
  }

  String get updatedLabel {
    final value = publishedAt ?? updatedAt;
    if (value == null) return version;
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}
