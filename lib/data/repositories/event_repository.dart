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

  /// Yeni etkinlik oluşturma (create_new_event RPC)
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

  /// "Bu haftakiler" için etkinlikleri getirir.
  ///
  /// - Haftanın başlangıcı: Pazartesi 00:00
  /// - Haftanın bitişi: Sonraki Pazartesi 00:00 (end exclusive)
  /// - Sonuç: start_date'e göre sıralı EventModel listesi
  Future<List<EventModel>> getThisWeekEvents() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Haftanın başlangıcı (Pazartesi)
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      // Haftanın bitişi (Pazartesi + 7 gün) – [start, end) aralığı
      final weekEnd = weekStart.add(const Duration(days: 7));

      final rows = await _eventService.getEventsInRange(
        start: weekStart,
        end: weekEnd,
      );

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
        'Bu haftanın etkinlikleri alınırken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Supabase satırını UI'da kullanılan EventModel'e dönüştürür.
  ///
  /// Şu an için:
  ///  - date  -> start_date
  ///  - location -> location_name (yoksa location_place_name)
  ///  - imageUrl -> cover_image_url
  ///  - attendeeCount -> current_participants / max_participants / 0
  EventModel _mapRowToEventModel(Map<String, dynamic> row) {
    final dynamic startDateRaw = row['start_date'];
    final DateTime startDate = _parseDateTime(startDateRaw);

    // Lokasyon adı (iki farklı kolon ihtimaline göre)
    final String locationName =
        (row['location_name'] as String?) ??
            (row['location_place_name'] as String?) ??
            '';

    // Katılımcı sayısı:
    // 1) current_participants varsa onu
    // 2) yoksa max_participants
    // 3) ikisi de yoksa 0
    final int attendeeCount = _parseInt(
      row['current_participants'] ?? row['max_participants'],
    );

    return EventModel(
      id: row['id']?.toString() ?? '',
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      date: startDate,
      location: locationName,
      imageUrl: row['cover_image_url'] as String? ?? '',
      attendeeCount: attendeeCount,
      // Kategoriler için şimdilik boş; ileride join ile doldururuz
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
