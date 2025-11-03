class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final int attendeeCount;
  final bool isLiked;
  final List<String> categories;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.attendeeCount,
    this.isLiked = false,
    this.categories = const [],
  });

  // Mock data için factory
  factory EventModel.mock({
    required String id,
    required String title,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: 'Etkinlik açıklaması buraya gelecek',
      date: DateTime.now().add(Duration(days: int.parse(id))),
      location: 'Konya',
      imageUrl: 'https://picsum.photos/seed/$id/400/300',
      attendeeCount: 50 + int.parse(id) * 10,
      categories: ['Müzik', 'Konser'],
    );
  }

  // Tarih formatı için helper
  String get formattedDate {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? imageUrl,
    int? attendeeCount,
    bool? isLiked,
    List<String>? categories,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      isLiked: isLiked ?? this.isLiked,
      categories: categories ?? this.categories,
    );
  }
}