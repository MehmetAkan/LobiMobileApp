import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/errors/app_exception.dart';

/// EventService - Etkinliklerle ilgili ham Supabase işlemlerini yönetir.
///
/// Sorumluluklar:
/// 1. 'create_new_event' RPC'sini çağırarak yeni veri eklemek.
/// 2. 'event_covers' Storage bucket'ına resim yüklemek (upload).
/// 3. Etkinlikleri Supabase tablosundan okumak.
class EventService {
  final SupabaseClient _client;

  EventService(this._client);

  /// 'create_new_event' RPC'sini çağırarak yeni bir etkinlik ekler.
  ///
  /// [data] - Repository'den gelen, veritabanı sütun adlarıyla eşleşen bir Map.
  /// Geriye eklenen verinin Map'ini döndürür.
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    try {
      // ✨ RLS 'infinite recursion' hatasını çözmek için
      // .insert() yerine SECURITY DEFINER bir RPC fonksiyonu çağırıyoruz.

      // 1. Repository'den gelen Map'in key'lerini RPC'nin beklediği
      // argüman adlarına ('_in' son eki ile) dönüştür.
      final rpcParams = data.map((key, value) {
        // SQL fonksiyonumuzdaki argüman adlarıyla eşleştiriyoruz.
        return MapEntry('${key}_in', value);
      });

      // 2. 'organizer_id'yi Map'ten siliyoruz, çünkü yeni SQL fonksiyonumuz
      // bunu 'auth.uid()' ile alarak daha güvenli hale getiriyor.
      rpcParams.remove('organizer_id_in');

      // 3. RPC'yi (Remote Procedure Call) çağır
      final result = await _client
          .rpc(
            'create_new_event', // SQL'de oluşturduğumuz fonksiyonun adı
            params: rpcParams, // Fonksiyonun argümanları
          )
          .select() // .select() zinciri RPC'lerde de çalışır
          .single(); // Tek bir satır (yeni eklenen) döndürmesini bekliyoruz

      return result as Map<String, dynamic>;
    } catch (e) {
      // Supabase'den gelen PostgrestError veya diğer hataları yakala
      throw _handleError(e, 'createEvent');
    }
  }

  /// Belirli bir tarih aralığındaki etkinlikleri getirir.
  ///
  /// [start] dahil, [end] hariç olacak şekilde [start, end) aralığını kullanır.
  /// Örn: Bu hafta için Pazartesi 00:00 - gelecek Pazartesi 00:00.
  Future<List<Map<String, dynamic>>> getEventsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final response = await _client.rpc(
        'get_events_in_range',
        params: {
          'start_date_in': start.toIso8601String(),
          'end_date_in': end.toIso8601String(),
        },
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getEventsInRange');
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingEventsPaginated({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await _client.rpc(
        'get_upcoming_events_paginated',
        params: {'limit_in': limit, 'offset_in': offset},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getUpcomingEventsPaginated');
    }
  }

  /// Bir kapak fotoğrafını Supabase Storage'a yükler.
  ///
  /// (Bu fonksiyonda değişiklik yok)
  Future<String> uploadCoverImage({
    required File file,
    required String userId,
  }) async {
    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      final fileName =
          'cover_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '$userId/$fileName';

      await _client.storage
          .from('event_covers')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _client.storage
          .from('event_covers')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw _handleError(e, 'uploadCoverImage');
    }
  }

  Future<List<Map<String, dynamic>>> getPopularEvents({
    required int limit,
  }) async {
    try {
      final response = await _client.rpc(
        'get_popular_events',
        params: {'limit_in': limit},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getPopularEvents');
    }
  }

  /// Hata yönetimi
  AppException _handleError(Object error, String context) {
    final String prefix = 'EventService ($context):';

    if (error is PostgrestException) {
      return DatabaseException(
        '$prefix ${error.message}',
        code: error.code,
        originalError: error,
      );
    }

    if (error is StorageException) {
      return NetworkException('$prefix ${error.message}', originalError: error);
    }

    return UnknownException(
      '$prefix ${error.toString()}',
      originalError: error,
    );
  }
}
