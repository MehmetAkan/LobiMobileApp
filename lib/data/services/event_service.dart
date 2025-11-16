import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/errors/app_exception.dart';


class EventService {
  final SupabaseClient _client;

  EventService(this._client);


  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    try {

      final rpcParams = data.map((key, value) {
        return MapEntry('${key}_in', value);
      });

      rpcParams.remove('organizer_id_in');

      // 3. RPC'yi (Remote Procedure Call) çağır
      final result = await _client
          .rpc(
            'create_new_event', 
            params: rpcParams, 
          )
          .select() 
          .single();

      return result as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e, 'createEvent');
    }
  }


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
  Future<void> incrementEventViewCount(String eventId) async {
    try {
      await _client.rpc(
        'increment_event_view_count',
        params: {'event_id_in': eventId},
      );
    } catch (e) {
      throw _handleError(e, 'incrementEventViewCount');
    }
  }

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
