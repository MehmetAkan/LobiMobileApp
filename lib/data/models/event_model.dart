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
  final String? organizerName; // Organizer full name
  final String? organizerUsername; // Organizer username
  final String? organizerPhotoUrl; // Organizer profile photo
  final int attendeeCount;
  final bool isLiked;
  final List<String> categories;
  final String? categoryId; // Added for category tracking
  final bool requiresApproval;
  final bool isPublic; // Event visibility (true = public, false = private)
  final bool isCancelled; // Event cancellation status
  final DateTime? cancelledAt; // When event was cancelled
  final String? cancellationReason; // Optional reason for cancellation
  final String?
  attendanceStatus; // User's attendance status (null if organizer)
  final DateTime? serverCurrentTime; // Server UTC time from PostgreSQL NOW()
  final String shareSlug; // Deep linking slug (10 chars alphanumeric)

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
    this.organizerName,
    this.organizerUsername,
    this.organizerPhotoUrl,
    required this.attendeeCount,
    this.isLiked = false,
    this.categories = const [],
    this.categoryId,
    this.requiresApproval = false,
    this.isPublic = true, // Default to public
    this.isCancelled = false, // Default to not cancelled
    this.cancelledAt,
    this.cancellationReason,
    this.attendanceStatus, // Null if user is organizer
    this.serverCurrentTime, // Server time for state calculations
    required this.shareSlug, // Required for deep linking
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
      shareSlug: 'mock${id.padLeft(6, '0')}', // Mock share slug
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
    String? organizerName,
    String? organizerUsername,
    String? organizerPhotoUrl,
    int? attendeeCount,
    bool? isLiked,
    List<String>? categories,
    String? categoryId,
    bool? requiresApproval,
    bool? isPublic,
    bool? isCancelled,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? attendanceStatus,
    DateTime? serverCurrentTime,
    String? shareSlug,
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
      organizerName: organizerName ?? this.organizerName,
      organizerUsername: organizerUsername ?? this.organizerUsername,
      organizerPhotoUrl: organizerPhotoUrl ?? this.organizerPhotoUrl,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      isLiked: isLiked ?? this.isLiked,
      categories: categories ?? this.categories,
      categoryId: categoryId ?? this.categoryId,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      isPublic: isPublic ?? this.isPublic,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      serverCurrentTime: serverCurrentTime ?? this.serverCurrentTime,
      shareSlug: shareSlug ?? this.shareSlug,
    );
  }
}
