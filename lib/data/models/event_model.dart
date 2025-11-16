class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDate;
  final String location;
  final String? locationSecondary;
  final String imageUrl;
  final String? organizerId;
  final int attendeeCount;
  final bool isLiked;
  final List<String> categories;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
      this.locationSecondary,    
    this.organizerId,
    this.endDate,
    required this.imageUrl,
    required this.attendeeCount,
    this.isLiked = false,
    this.categories = const [],
  });

  // Mock data için factory
  factory EventModel.mock({required String id, required String title}) {
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
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
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
      String? locationSecondary, 
    String? imageUrl,
    DateTime? endDate,
    String? organizerId,
    int? attendeeCount,
    bool? isLiked,
    List<String>? categories,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
       locationSecondary: locationSecondary ?? this.locationSecondary,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      isLiked: isLiked ?? this.isLiked,
      categories: categories ?? this.categories,
    );
  }
}
