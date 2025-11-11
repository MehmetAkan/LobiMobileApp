/// CategoryModel - Etkinlik kategorisi modeli
/// 
/// Supabase'deki event_categories tablosundan gelen verileri temsil eder.
/// Icon ve renk bilgileri kod tarafında yönetilir.
class CategoryModel {
  final String id;
  final String name;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.isActive = true,
    this.createdAt,
  });

  /// Supabase'den gelen JSON'u model'e çevir
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_order': displayOrder,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Kategori icon path'i (kod tarafında mapping)
  String get svgPath {
    switch (name) {
      case 'Spor & Aktivite':
        return 'assets/images/system/category/sport-category-icon.svg';
      case 'Sanat & Kültür':
        return 'assets/images/system/category/art-category-icon.svg';
      case 'Eğitim & Workshop':
        return 'assets/images/system/category/education-category-icon.svg';
      case 'Müzik & Konser':
        return 'assets/images/system/category/concert-category-icon.svg';
      case 'Yemek & İçecek':
        return 'assets/images/system/category/food-category-icon.svg';
      case 'Oyun & Eğlence':
        return 'assets/images/system/category/film-category-icon.svg'; // Geçici
      case 'Sağlık & Wellness':
        return 'assets/images/system/category/heart-category-icon.svg';
      case 'İş & Networking':
        return 'assets/images/system/category/tech-category-icon.svg'; // Geçici
      case 'Doğa & Açık Hava':
        return 'assets/images/system/category/travel-category-icon.svg';
      case 'Tiyatro & Gösteri':
        return 'assets/images/system/category/theater-category-icon.svg';
      default:
        return 'assets/images/system/category/art-category-icon.svg'; // Default
    }
  }

  /// Kategori rengi (kod tarafında mapping)
  int get colorValue {
    switch (name) {
      case 'Spor & Aktivite':
        return 0xFFFF5733;
      case 'Sanat & Kültür':
        return 0xFFC70039;
      case 'Eğitim & Workshop':
        return 0xFF900C3F;
      case 'Müzik & Konser':
        return 0xFF581845;
      case 'Yemek & İçecek':
        return 0xFFFFC300;
      case 'Oyun & Eğlence':
        return 0xFFDAF7A6;
      case 'Sağlık & Wellness':
        return 0xFF33FF57;
      case 'İş & Networking':
        return 0xFF3357FF;
      case 'Doğa & Açık Hava':
        return 0xFF57FF33;
      case 'Tiyatro & Gösteri':
        return 0xFFFF33F5;
      default:
        return 0xFF888888; // Default gray
    }
  }

  /// Mock kategoriler (test için - SADECE FALLBACK)
  static List<CategoryModel> getMockCategories() {
    return [
      CategoryModel(id: 'a8b42e30-db72-4145-b8df-bd533fdda910', name: 'Spor & Aktivite', displayOrder: 1),
      CategoryModel(id: '62887dd5-0aef-4fb7-be89-b0ff764289bd', name: 'Sanat & Kültür', displayOrder: 2),
      CategoryModel(id: '920556ac-fd78-4018-af3c-61af54d251b6', name: 'Eğitim & Workshop', displayOrder: 3),
      CategoryModel(id: 'd1e1952c-f91d-41e2-9201-a41ea483ae36', name: 'Müzik & Konser', displayOrder: 4),
      CategoryModel(id: '07c2a00e-64d6-4b80-a2ae-8097e902a1fd', name: 'Yemek & İçecek', displayOrder: 5),
      CategoryModel(id: '673f18b8-a1ff-4b02-8b65-57c7266a2216', name: 'Oyun & Eğlence', displayOrder: 6),
      CategoryModel(id: '05a073c1-5c63-4946-93b9-287f667fad4b', name: 'Sağlık & Wellness', displayOrder: 7),
      CategoryModel(id: 'df0fb212-de15-4182-b123-0f90275ea642', name: 'İş & Networking', displayOrder: 8),
      CategoryModel(id: 'cf32c59d-6361-4100-8504-39e17a106f49', name: 'Doğa & Açık Hava', displayOrder: 9),
      CategoryModel(id: 'c38224ba-7309-43a3-bc59-1485060291b8', name: 'Tiyatro & Gösteri', displayOrder: 10),
    ];
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}