import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/services/location_service.dart';
import '../data/services/places_service.dart';

/// LocationService Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// PlacesService Provider
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

/// Kullanıcının mevcut konumu
/// 
/// Ana sayfada "Yakınımdaki Etkinlikler" için kullanılacak
final userLocationProvider = FutureProvider<Position?>((ref) async {
  final service = ref.read(locationServiceProvider);

  try {
    return await service.getCurrentPosition();
  } catch (e) {
    print('Konum alınamadı: $e');
    return null;
  }
});

/// Seçili konum
/// 
/// Etkinlik oluştururken seçilen konum burada saklanır
final selectedLocationProvider = StateProvider<LocationModel?>((ref) => null);

/// Yer arama notifier
/// 
/// Kullanıcı yazarken Places API'den sonuç getir
class PlaceSearchNotifier
    extends StateNotifier<AsyncValue<List<PlacePrediction>>> {
  PlaceSearchNotifier(this.placesService) : super(const AsyncValue.data([]));

  final PlacesService placesService;
  String? _sessionToken;

  /// Yer ara
  Future<void> searchPlaces({required String query}) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Session token yoksa oluştur (maliyet optimizasyonu)
      _sessionToken ??= placesService.generateSessionToken();

      final results = await placesService.searchPlaces(
        query: query,
        sessionToken: _sessionToken,
      );

      state = AsyncValue.data(results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Arama sonuçlarını temizle
  void clearResults() {
    state = const AsyncValue.data([]);
    _sessionToken = null;
  }

  /// Yer seçildiğinde detayları al
  /// 
  /// PlaceId'den koordinat ve adres bilgisini çek
  Future<LocationModel?> selectPlace(String placeId) async {
    try {
      final location = await placesService.getPlaceDetails(
        placeId: placeId,
      );

      // Session token'ı sıfırla (Places API billing için)
      _sessionToken = null;

      return location;
    } catch (e) {
      print('Yer detayları alınamadı: $e');
      return null;
    }
  }
}

/// Yer arama provider
final placeSearchProvider = StateNotifierProvider<PlaceSearchNotifier,
    AsyncValue<List<PlacePrediction>>>(
  (ref) {
    final placesService = ref.read(placesServiceProvider);
    return PlaceSearchNotifier(placesService);
  },
);

/// Mesafe hesaplama helper
/// 
/// İki konum arası mesafe (km)
final distanceCalculatorProvider = Provider<
    double Function({
      required double lat1,
      required double lon1,
      required double lat2,
      required double lon2,
    })>((ref) {
  final service = ref.read(locationServiceProvider);

  return ({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return service.calculateDistance(
      startLatitude: lat1,
      startLongitude: lon1,
      endLatitude: lat2,
      endLongitude: lon2,
    );
  };
});