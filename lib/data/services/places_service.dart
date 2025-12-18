import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'location_service.dart';

/// PlacePrediction - Yer önerisi modeli
///
/// Kullanıcı yazarken gösterilecek arama sonuçları
class PlacePrediction {
  final String placeId;
  final String mainText; // "Antalya Üniversitesi"
  final String secondaryText; // "Konyaaltı, Antalya"
  final String fullText; // Tam adres

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>?;

    return PlacePrediction(
      placeId: json['place_id'] as String,
      mainText: structuredFormatting?['main_text'] as String? ?? '',
      secondaryText: structuredFormatting?['secondary_text'] as String? ?? '',
      fullText: json['description'] as String? ?? '',
    );
  }
}

/// PlacesService - Google Places API servisi
///
/// Kullanım alanları:
/// 1. Etkinlik oluştururken yer arama
/// 2. Yer detaylarını alma (koordinat, adres, vs.)
class PlacesService {
  final String _apiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  PlacesService({String? apiKey})
    : _apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Yer arama (Autocomplete)
  ///
  /// Kullanıcı yazarken otomatik tamamlama önerileri
  ///
  /// Örnek:
  /// ```dart
  /// final predictions = await searchPlaces(
  ///   query: 'Antalya Üni',
  ///   sessionToken: '123456',
  /// );
  /// ```
  Future<List<PlacePrediction>> searchPlaces({
    required String query,
    String? sessionToken,
    String language = 'tr',
  }) async {
    if (query.isEmpty) return [];
    if (_apiKey.isEmpty) {
      throw Exception(
        'Google Maps API key bulunamadı. .env dosyasını kontrol edin.',
      );
    }

    try {
      final params = {
        'input': query,
        'key': _apiKey,
        'language': language,
        'components': 'country:tr', // Sadece Türkiye
        if (sessionToken != null) 'sessiontoken': sessionToken,
      };

      final uri = Uri.parse(
        '$_baseUrl/place/autocomplete/json',
      ).replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
              .toList();
          return predictions;
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Places API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Places search error', e);
      return [];
    }
  }

  /// Yer detaylarını al
  ///
  /// PlaceId'den tam konum bilgisi (koordinat, adres, ilçe, şehir)
  ///
  /// Örnek:
  /// ```dart
  /// final location = await getPlaceDetails(
  ///   placeId: 'ChIJ...',
  /// );
  /// ```
  Future<LocationModel?> getPlaceDetails({
    required String placeId,
    String language = 'tr',
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Google Maps API key bulunamadı.');
    }

    try {
      final params = {
        'place_id': placeId,
        'key': _apiKey,
        'language': language,
        'fields': 'name,formatted_address,geometry,address_components',
      };

      final uri = Uri.parse(
        '$_baseUrl/place/details/json',
      ).replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>;
          final geometry = result['geometry'] as Map<String, dynamic>;
          final location = geometry['location'] as Map<String, dynamic>;
          final addressComponents = result['address_components'] as List;

          // Şehir, ilçe, ülke bilgilerini çıkar
          String? city;
          String? district;
          String? country;

          for (var component in addressComponents) {
            final types = component['types'] as List;

            if (types.contains('administrative_area_level_1')) {
              // Şehir (Antalya, İstanbul, vs.)
              city = component['long_name'] as String?;
            } else if (types.contains('administrative_area_level_2')) {
              // İlçe (Konyaaltı, Muratpaşa, vs.)
              district = component['long_name'] as String?;
            } else if (types.contains('country')) {
              country = component['long_name'] as String?;
            }
          }

          return LocationModel(
            placeName: result['name'] as String? ?? '',
            address: result['formatted_address'] as String? ?? '',
            latitude: (location['lat'] as num).toDouble(),
            longitude: (location['lng'] as num).toDouble(),
            city: city,
            district: district,
            country: country,
          );
        } else {
          throw Exception('Place Details Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Place details error', e);
      return null;
    }
  }

  /// Session token oluştur
  ///
  /// Maliyet optimizasyonu için:
  /// Aynı session'daki autocomplete + details çağrıları tek istek sayılır
  String generateSessionToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
