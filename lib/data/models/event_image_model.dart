/// EventImageModel - Etkinlik resim kütüphanesi modeli
///
/// Supabase'deki event_images tablosundan gelen verileri temsil eder.
/// Kullanıcı etkinlik oluştururken bu resimlerden birini seçebilir.
///
/// Kullanım:
/// ```dart
/// final image = EventImageModel.fromJson(data);
/// print(image.url);
/// print(image.category.name);
/// ```
class EventImageModel {
  final String id;
  final String url;
  final String categoryId;
  final List<String> tags;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventImageModel({
    required this.id,
    required this.url,
    required this.categoryId,
    required this.tags,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Supabase'den gelen JSON'u model'e çevir
  factory EventImageModel.fromJson(Map<String, dynamic> json) {
    return EventImageModel(
      id: json['id'] as String,
      url: json['url'] as String,
      categoryId: json['category_id'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Model'i JSON'a çevir (Supabase'e gönderirken)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'category_id': categoryId,
      'tags': tags,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Resmin belirli bir tag'i içerip içermediğini kontrol et
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()));
  }

  /// Birden fazla tag ile eşleşme kontrolü
  bool matchesTags(List<String> searchTags) {
    if (searchTags.isEmpty) return true;
    
    return searchTags.any((searchTag) => hasTag(searchTag));
  }

  /// CopyWith - Güncelleme için
  EventImageModel copyWith({
    String? id,
    String? url,
    String? categoryId,
    List<String>? tags,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventImageModel(
      id: id ?? this.id,
      url: url ?? this.url,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Debug için
  @override
  String toString() {
    return 'EventImageModel(id: $id, url: $url, categoryId: $categoryId, tags: $tags)';
  }

  /// Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventImageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}