import 'dart:io';

import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
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

  /// Get event by share slug (for deep linking)
  Future<EventModel?> getEventBySlug(String shareSlug) async {
    try {
      final rows = await _eventService.getEventBySlug(shareSlug);

      if (rows.isEmpty) {
        return null; // Event not found
      }

      return _mapToEventModel(rows.first);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Etkinlik yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Get recommended events based on user's interests
  Future<List<EventModel>> getRecommendedEvents({
    required String userId,
    int limit = 5,
  }) async {
    try {
      AppLogger.debug(
        '📦 REPOSITORY: getRecommendedEvents called for user: $userId',
      );

      final rows = await _eventService.getRecommendedEvents(
        userId: userId,
        limit: limit,
      );

      AppLogger.debug(
        '📦 REPOSITORY: Received ${rows.length} events from service',
      );

      final events = rows
          .map<EventModel>((row) => _mapToEventModel(row))
          .toList();

      AppLogger.debug(
        '📦 REPOSITORY: Mapped to ${events.length} EventModel objects',
      );

      return events;
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.debug('📦 REPOSITORY ERROR: $e');
      throw UnknownException(
        'Önerilen etkinlikler alınırken bir hata oluştu',
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

  Future<List<EventModel>> getUserUpcomingEvents(String userId) async {
    try {
      final rows = await _eventService.getUserUpcomingEvents(userId: userId);
      return rows.map((row) => _mapToEventModel(row)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Yaklaşan etkinlikler alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  Future<List<EventModel>> getUserPastEvents(String userId) async {
    try {
      final rows = await _eventService.getUserPastEvents(userId: userId);
      return rows.map((row) => _mapToEventModel(row)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Geçmiş etkinlikler alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  Future<List<EventModel>> getUserAttendedEvents(String userId) async {
    try {
      final rows = await _eventService.getUserAttendedEventsForProfile(
        userId: userId,
      );
      return rows.map((row) => _mapToEventModel(row)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Katıldığınız etkinlikler alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  Future<List<EventModel>> getUserOrganizedEvents(String userId) async {
    try {
      final rows = await _eventService.getUserOrganizedEventsForProfile(
        userId: userId,
      );
      return rows.map((row) => _mapToEventModel(row)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        'Oluşturduğunuz etkinlikler alınırken bir hata oluştu',
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
    final String? locationSecondary = row['location_address'] as String?;
    final int attendeeCount = _parseInt(row['participant_count']);

    final String? organizerId = row['organizer_id'] as String?;

    final bool requiresApproval = row['requires_approval'] as bool? ?? false;
    final bool isPublic = row['is_public'] as bool? ?? true;
    final bool isCancelled = row['is_cancelled'] as bool? ?? false;

    DateTime? cancelledAt;
    if (row['cancelled_at'] != null) {
      cancelledAt = _parseDateTime(row['cancelled_at']);
    }

    final String? cancellationReason = row['cancellation_reason'] as String?;
    final String? attendanceStatus = row['attendance_status'] as String?;

    // Organizer info
    final String? organizerName = row['organizer_name'] as String?;
    final String? organizerUsername = row['organizer_username'] as String?;
    final String? organizerPhotoUrl = row['organizer_photo_url'] as String?;

    // Server current time for state calculations
    DateTime? serverCurrentTime;
    if (row['server_current_time'] != null) {
      serverCurrentTime = _parseDateTime(row['server_current_time']);
    }

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
      organizerName: organizerName,
      organizerUsername: organizerUsername,
      organizerPhotoUrl: organizerPhotoUrl,
      attendeeCount: attendeeCount,
      categories: const [],
      categoryId: row['category_id'] as String?,
      requiresApproval: requiresApproval,
      isPublic: isPublic,
      isCancelled: isCancelled,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
      attendanceStatus: attendanceStatus,
      serverCurrentTime: serverCurrentTime,
      shareSlug: row['share_slug'] as String? ?? '', // Deep link slug
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
