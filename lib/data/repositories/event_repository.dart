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
        // ✨ DÜZELTME: 'organizer_id' satırı kaldırıldı.
        // Yeni 'create_new_event' SQL fonksiyonumuz bunu 'auth.uid()'
        // ile güvenli bir şekilde hallediyor.
      };

      // 5. EventService aracılığıyla veritabanına kaydet
      return await _eventService.createEvent(dataMap);
    } catch (e) {
      // Şimdilik üst kata aynen fırlatıyoruz (AppException ise UI zaten biliyor)
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

    // Supabase satırlarını EventModel'e çevir
    var events = rows
        .map<EventModel>((row) => _mapRowToEventModel(row))
        .toList();

    // 🔥 ÖNEMLİ KISIM: Geçmiş etkinlikleri ele
    //
    // Şu andan önce başlamış olan etkinlikler listede görünmesin:
    //  - start_date < now  => geçmiş
    //  - start_date >= now => gelecekte veya şu an
    final nowUtc = DateTime.now().toUtc();
    events = events
        .where((event) => !event.date.isBefore(nowUtc))
        .toList();

    // Tarihe göre sırala (en yakından en uzağa)
    events.sort((a, b) => a.date.compareTo(b.date));

    return events;
  } catch (e) {
    // mevcut hata yönetimin nasıl ise aynen bırak
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
          .map<EventModel>((row) => _mapRowToEventModel(row))
          .toList();

      return events;
    } on AppException {
      // Servis zaten AppException üretiyor, aynen fırlat
      rethrow;
    } catch (e) {
      // Beklenmeyen hatalar
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
          .map<EventModel>((row) => _mapRowToEventModel(row))
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

  EventModel _mapRowToEventModel(Map<String, dynamic> row) {
    final dynamic startDateRaw = row['start_date'];
    final DateTime startDate = _parseDateTime(startDateRaw);

    // Lokasyon adı
    final String locationName = (row['location_name'] as String?) ?? '';

    // Katılımcı sayısı: participant_count kolonundan
    final int attendeeCount = _parseInt(row['participant_count']);

    return EventModel(
      id: row['id']?.toString() ?? '',
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      date: startDate,
      location: locationName,
      imageUrl: row['cover_image_url'] as String? ?? '',
      attendeeCount: attendeeCount,
      categories: const [],
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
