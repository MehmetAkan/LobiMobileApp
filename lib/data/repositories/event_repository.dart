import 'dart:io';
import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/data/models/category_model.dart';
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
      rethrow;
    }
  }
}