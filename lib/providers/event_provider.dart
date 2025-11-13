import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_visibility_modal.dart';

/// EventRepository'yi GetIt'ten alıp Riverpod'a sağlayan basit provider.
/// Tıpkı 'categoryRepositoryProvider' gibi.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return getIt<EventRepository>();
});

/// Etkinlik oluşturma işleminin durumunu yöneten StateNotifier.
///
/// Bu provider, 'Kaydet' butonuna basıldığında UI'ın
/// [Yükleniyor, Hata Aldı, Başarılı] durumlarını bilmesini sağlar.
final createEventControllerProvider =
    StateNotifierProvider<CreateEventController, AsyncValue<void>>((ref) {
  return CreateEventController(ref);
});

class CreateEventController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CreateEventController(this._ref)
      : super(const AsyncValue.data(null)); // Başlangıç durumu: 'idle' (boşta)

  /// UI (CreateEventScreen) tarafından çağrılacak ana fonksiyon.
  /// Gerekli tüm parametreleri alır ve repository'ye iletir.
  ///
  /// Başarı durumunda 'true', hata durumunda 'false' döndürür.
  Future<bool> createEvent({
    required String title,
    required String? description,
    required String? coverPhotoUrl,
    required DateTime? startDate,
    required DateTime? endDate,
    required LocationModel? location,
    required CategoryModel? category,
    required EventVisibility visibility,
    required bool isApprovalRequired,
    required int? capacity,
  }) async {
    
    // --- ÖN DOĞRULAMA (VALIDATION) ---
    // UI'dan gelen verilerin zorunlu alanlarını kontrol edelim.
    // (Daha detaylı validasyon eklenebilir)
    try {
      if (title.isEmpty) {
        throw Exception('Etkinlik başlığı boş olamaz.');
      }
      if (startDate == null || endDate == null) {
        throw Exception('Başlangıç ve bitiş tarihi seçilmelidir.');
      }
      if (location == null) {
        throw Exception('Konum seçilmelidir.');
      }
      if (category == null) {
        throw Exception('Kategori seçilmelidir.');
      }
      
      // Durumu 'yükleniyor' olarak ayarla
      state = const AsyncValue.loading();

      // Repository'yi provider'dan oku
      final repository = _ref.read(eventRepositoryProvider);

      // Repository'deki createEvent metodunu çağır
      await repository.createEvent(
        title: title,
        description: description,
        coverPhotoUrl: coverPhotoUrl,
        startDate: startDate,
        endDate: endDate,
        location: location,
        category: category,
        visibility: visibility,
        isApprovalRequired: isApprovalRequired,
        capacity: capacity,
      );

      // İşlem başarılı, durumu 'boşta'ya (data=null) geri döndür
      state = const AsyncValue.data(null);
      return true; // Başarılı

    } catch (e, st) {
      // Hata oluştu, durumu 'hata' olarak ayarla
      state = AsyncValue.error(e, st);
      return false; // Başarısız
    }
  }
}