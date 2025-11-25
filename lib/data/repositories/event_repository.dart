import 'dart:io';

import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_visibility_modal.dart';

class EventRepository {
  final EventService _eventService;
  final AuthRepository _authRepository;

  EventRepository(this._eventService, this._authRepository);

  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String? description,
    required String? coverPhotoUrl,
    required DateTime startDate,
    required DateTime endDate,
    required LocationModel location,
    required CategoryModel category,
    required EventVisibility visibility,
    required bool isApprovalRequired,
    required int? capacity,
  }) async {
    try {
      // 1. Kullanıcı ID'sini al (Sadece resim yükleme için gerekli)
      final userId = _authRepository.currentUser?.id;
      if (userId == null) {
        throw AuthenticationException(
          'Etkinlik oluşturulamadı: Geçerli bir kullanıcı oturumu bulunamadı.',
        );
      }

      String? finalCoverImageUrl = coverPhotoUrl;

      // 2. Resim yükleme mantığı
      if (coverPhotoUrl != null && !coverPhotoUrl.startsWith('http')) {
        final file = File(coverPhotoUrl);

        // 3. Dosyayı Storage'a yükle
        finalCoverImageUrl = await _eventService.uploadCoverImage(
          file: file,
          userId: userId, // RLS politikamız için
        );
      }

      // 4. Veritabanı şemasına göre Map'i hazırla
      final Map<String, dynamic> dataMap = {
        'title': title,
        'description': description,
        'cover_image_url': finalCoverImageUrl,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'location_name': location.placeName,
        'location_address': location.address,
        'location_lat': location.latitude,
        'location_lng': location.longitude,
        'city': location.city,
        'district': location.district,
        'is_public': visibility == EventVisibility.public,
        'requires_approval': isApprovalRequired,
        'max_participants': capacity,
        'category_id': category.id,
      };
      return await _eventService.createEvent(dataMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getThisWeekEvents() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final rows = await _eventService.getEventsInRange(
        start: weekStart,
        end: weekEnd,
      );

      var events = rows
          .map<EventModel>((row) => _mapToEventModel(row))
          .toList();

      final nowUtc = DateTime.now().toUtc();
      events = events.where((event) => !event.date.isBefore(nowUtc)).toList();
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getUpcomingEventsPage({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final rows = await _eventService.getUpcomingEventsPaginated(
        limit: limit,
        offset: offset,
      );

      final events = rows
          .map<EventModel>((row) => _mapToEventModel(row))
          .toList();

      return events;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Etkinlikler alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  Future<List<EventModel>> getPopularEvents({int limit = 5}) async {
    try {
      final rows = await _eventService.getPopularEvents(limit: limit);

      final events = rows
          .map<EventModel>((row) => _mapToEventModel(row))
          .toList();

      return events;
    } on AppException {
      // Servis zaten AppException üretiyor, aynen yukarı fırlat
      rethrow;
    } catch (e) {
      // Beklenmeyen hataları UnknownException'a çevir
      throw UnknownException(
        'Popüler etkinlikler alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  Future<void> incrementEventViewCount(String eventId) async {
    try {
      await _eventService.incrementEventViewCount(eventId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Etkinlik görüntülenme sayısı artırılırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Get single event by ID
  Future<EventModel> getEventById(String eventId) async {
    try {
      final row = await _eventService.getEventById(eventId);
      return _mapToEventModel(row);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Etkinlik detayı alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  EventModel _mapToEventModel(Map<String, dynamic> row) {
    // Tarih parse
    final dynamic startDateRaw = row['start_date'];
    DateTime startDate;
    if (startDateRaw is DateTime) {
      startDate = startDateRaw;
    } else {
      startDate = _parseDateTime(startDateRaw);
    }

    // End date parse
    DateTime? endDate;
    final dynamic endDateRaw = row['end_date'];
    if (endDateRaw != null) {
      endDate = endDateRaw is DateTime
          ? endDateRaw
          : _parseDateTime(endDateRaw);
    }

    // Diğer alanlar
    final String locationName = (row['location_name'] as String?) ?? '';
    final String? locationSecondary = row['location_secondary_text'] as String?;
    final int attendeeCount = _parseInt(row['participant_count']);

    final String? organizerId = row['organizer_id'] as String?;

    final bool requiresApproval = row['requires_approval'] as bool? ?? false;

    return EventModel(
      id: row['id']?.toString() ?? '',
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      date: startDate,
      endDate: endDate,
      location: locationName,
      locationSecondary: locationSecondary,
      imageUrl: row['cover_image_url'] as String? ?? '',
      organizerId: organizerId,
      attendeeCount: attendeeCount,
      categories: const [],
      categoryId: row['category_id'] as String?, // Parse category_id
      requiresApproval: requiresApproval,
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);

    throw UnknownException(
      'Geçersiz tarih formatı: $value',
      originalError: value,
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
