import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// LocationModel - Konum verisi modeli
/// 
/// Supabase'e kaydedilecek ve ekranlarda gösterilecek konum bilgisi
class LocationModel {
  final String placeName; // "Antalya Üniversitesi"
  final String address; // "Dumlupınar Bulvarı, Kampüs..."
  final double latitude;
  final double longitude;
  final String? city; // "Antalya"
  final String? district; // "Konyaaltı"
  final String? country; // "Türkiye"

  const LocationModel({
    required this.placeName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.country,
  });

  /// Google Maps LatLng objesi
  LatLng get latLng => LatLng(latitude, longitude);

  /// Kullanıcıya gösterilecek kısa metin
  String get displayText => placeName.isNotEmpty ? placeName : address;

  /// Detaylı adres (etkinlik kartlarında gösterilecek)
  String get detailAddress {
    final parts = <String>[];
    
    if (district != null && district!.isNotEmpty) {
      parts.add(district!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    
    return parts.isEmpty ? address : parts.join(', ');
  }

  /// Supabase'e kaydetmek için JSON
  Map<String, dynamic> toJson() => {
        'location_place_name': placeName,
        'location_address': address,
        'location_latitude': latitude,
        'location_longitude': longitude,
        'location_city': city,
        'location_district': district,
        'location_country': country,
      };

  /// Supabase'den okuma
  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        placeName: json['location_place_name'] as String? ?? '',
        address: json['location_address'] as String? ?? '',
        latitude: (json['location_latitude'] as num).toDouble(),
        longitude: (json['location_longitude'] as num).toDouble(),
        city: json['location_city'] as String?,
        district: json['location_district'] as String?,
        country: json['location_country'] as String?,
      );

  @override
  String toString() => displayText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// LocationService - Konum işlemleri servisi
/// 
/// Kullanım alanları:
/// 1. Kullanıcının mevcut konumunu alma
/// 2. Yakındaki etkinlikleri bulma (ilçe/mahalle bazında)
/// 3. Koordinat <-> Adres çevirme
/// 4. Mesafe hesaplama
class LocationService {
  /// Konum izni kontrolü
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Konum izni isteme
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kalıcı olarak reddedilmiş - kullanıcıyı ayarlara yönlendir
      await Geolocator.openLocationSettings();
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Konum servisi açık mı kontrol et
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Kullanıcının mevcut konumunu al
  /// 
  /// Throws: Exception - Konum servisi kapalı veya izin yok
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisi kapalı. Lütfen açın.');
    }

    final hasPermission = await this.hasLocationPermission();
    if (!hasPermission) {
      final granted = await requestLocationPermission();
      if (!granted) {
        throw Exception('Konum izni gerekli.');
      }
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Koordinatları adrese çevir (Reverse Geocoding)
  /// 
  /// İlçe ve mahalle bilgisini de alır
  Future<LocationModel?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      return LocationModel(
        placeName: place.name ?? '',
        address: [
          place.street,
          place.subLocality, // Mahalle
          place.locality, // İlçe
        ].where((e) => e != null && e.isNotEmpty).join(', '),
        latitude: latitude,
        longitude: longitude,
        city: place.administrativeArea, // Şehir
        district: place.subAdministrativeArea, // İlçe
        country: place.country,
      );
    } catch (e) {
      print('Reverse geocoding hatası: $e');
      return null;
    }
  }

  /// İki nokta arası mesafe hesapla (km cinsinden)
  /// 
  /// Haversine formülü kullanır
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // metre -> km
  }

  /// Kullanıcının konumuna göre etkinlikleri filtrele
  /// 
  /// İlçe ve mahalle bazında filtreleme için
  /// maxDistanceKm: Maksimum mesafe (km)
  Future<List<T>> filterEventsByDistance<T>({
    required List<T> events,
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    required double Function(T) getEventLatitude,
    required double Function(T) getEventLongitude,
  }) async {
    return events.where((event) {
      final distance = calculateDistance(
        startLatitude: userLatitude,
        startLongitude: userLongitude,
        endLatitude: getEventLatitude(event),
        endLongitude: getEventLongitude(event),
      );
      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Mesafeye göre sırala (yakından uzağa)
  List<T> sortEventsByDistance<T>({
    required List<T> events,
    required double userLatitude,
    required double userLongitude,
    required double Function(T) getEventLatitude,
    required double Function(T) getEventLongitude,
  }) {
    final eventsWithDistance = events.map((event) {
      final distance = calculateDistance(
        startLatitude: userLatitude,
        startLongitude: userLongitude,
        endLatitude: getEventLatitude(event),
        endLongitude: getEventLongitude(event),
      );
      return MapEntry(event, distance);
    }).toList();

    eventsWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return eventsWithDistance.map((e) => e.key).toList();
  }

  /// Mesafe metnini formatla
  /// 
  /// Kullanıcı dostu format: "2.5 km" veya "850 m"
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Google Maps uygulamasında aç
  /// 
  /// Kullanıcıya yönlendirme yapmak için
  Future<void> openInGoogleMaps(LocationModel location) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    // TODO: url_launcher paketi ile aç
    print('Google Maps açılıyor: $url');
  }

  /// Apple Maps'te aç (iOS için)
  Future<void> openInAppleMaps(LocationModel location) async {
    final url =
        'https://maps.apple.com/?q=${location.latitude},${location.longitude}';
    // TODO: url_launcher paketi ile aç
    print('Apple Maps açılıyor: $url');
  }
}