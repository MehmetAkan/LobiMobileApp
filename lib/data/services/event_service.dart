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
          .rpc('create_new_event', params: rpcParams)
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
      final path = file.path;

      // 1) Eğer asset yoluyorsa (ör: assets/images/system/events_cover/events_cover_4.jpg)
      //    Supabase'e upload ETME, direkt bu string'i kullan.
      if (path.startsWith('assets/')) {
        return path;
      }

      // 2) Güvenlik için: eğer bir şekilde http ile başlayan bir şey File olarak gelirse
      //    (normalde olmaması lazım) yine upload etme, olduğu gibi döndür.
      if (path.startsWith('http')) {
        return path;
      }

      // 3) Buraya geldiysek bu cihazdaki GERÇEK bir dosya yolu demektir => upload et
      final fileExtension = path.split('.').last.toLowerCase();
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
    String? excludeUserId,
  }) async {
    try {
      print(
        '⭐ POPULAR EVENTS: Being called with limit: $limit, excludeUserId: $excludeUserId',
      );

      final response = await _client.rpc(
        'get_popular_events',
        params: {
          'limit_in': excludeUserId != null ? limit * 5 : limit,
        }, // Fetch 5x more if filtering
      );

      var events = (response as List).cast<Map<String, dynamic>>();

      // If userId provided, exclude user's organized and participated events
      if (excludeUserId != null) {
        // Get user's participated events
        final userEvents = await _client
            .from('event_participants')
            .select('event_id')
            .eq('user_id', excludeUserId);

        final excludedEventIds = (userEvents as List)
            .map((e) => e['event_id'] as String)
            .toList();

        print(
          '⭐ POPULAR EVENTS: Excluding ${excludedEventIds.length} participant events',
        );

        // Filter out user's organized and participated events
        events = events
            .where((event) {
              final isOrganizer = event['organizer_id'] == excludeUserId;
              final isParticipant = excludedEventIds.contains(event['id']);
              return !isOrganizer && !isParticipant;
            })
            .take(limit)
            .toList();
      }

      print('⭐ POPULAR EVENTS: Returned ${events.length} events');

      return events;
    } catch (e) {
      throw _handleError(e, 'getPopularEvents');
    }
  }

  /// Get recommended events based on user's interests
  /// Returns events from user's favorite categories, fallback to popular events
  /// Uses Supabase RPC for efficient server-side filtering
  Future<List<Map<String, dynamic>>> getRecommendedEvents({
    required String userId,
    int limit = 5,
  }) async {
    try {
      final response = await _client.rpc(
        'get_recommended_events_for_user',
        params: {'p_user_id': userId, 'p_limit': limit},
      );

      final events = (response as List).cast<Map<String, dynamic>>();

      if (events.isNotEmpty) {}

      return events;
    } catch (e, stackTrace) {
      throw _handleError(e, 'getRecommendedEvents');
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

  /// Get event by share slug (for deep linking)
  Future<List<Map<String, dynamic>>> getEventBySlug(String shareSlug) async {
    try {
      final response = await _client.rpc(
        'get_event_by_share_slug',
        params: {'slug_param': shareSlug},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getEventBySlug');
    }
  }

  /// Get upcoming events by category (uses Supabase RPC for performance)
  Future<List<Map<String, dynamic>>> getEventsByCategory(
    String categoryId,
  ) async {
    try {
      final response = await _client.rpc(
        'get_events_by_category',
        params: {'category_id_in': categoryId, 'limit_in': 20},
      );

      if ((response as List).isNotEmpty) {}

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      throw _handleError(e, 'getEventsByCategory');
    }
  }

  /// Update existing event
  Future<void> updateEvent({
    required String eventId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client
          .from(AppConstants.eventsTable)
          .update(updates)
          .eq('id', eventId);
    } catch (e) {
      throw _handleError(e, 'updateEvent');
    }
  }

  Future<void> updateEventVisibility({
    required String eventId,
    required bool isPublic,
  }) async {
    try {
      await _client
          .from(AppConstants.eventsTable)
          .update({'is_public': isPublic})
          .eq('id', eventId);
    } catch (e) {
      throw _handleError(e, 'updateEventVisibility');
    }
  }

  /// Update event approval requirement
  Future<void> updateEventApprovalRequirement({
    required String eventId,
    required bool requiresApproval,
  }) async {
    try {
      await _client
          .from(AppConstants.eventsTable)
          .update({'requires_approval': requiresApproval})
          .eq('id', eventId);
    } catch (e) {
      throw _handleError(e, 'updateEventApprovalRequirement');
    }
  }

  /// Get user's upcoming events (attending or organizing)
  Future<List<Map<String, dynamic>>> getUserUpcomingEvents({
    required String userId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_user_upcoming_events',
        params: {'user_id_in': userId},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getUserUpcomingEvents');
    }
  }

  /// Get user's past events (attending or organizing)
  Future<List<Map<String, dynamic>>> getUserPastEvents({
    required String userId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_user_past_events',
        params: {'user_id_in': userId},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getUserPastEvents');
    }
  }

  /// Get user's attended events for profile (status = 'attended')
  Future<List<Map<String, dynamic>>> getUserAttendedEventsForProfile({
    required String userId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_user_attended_events_for_profile',
        params: {'user_id_in': userId},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getUserAttendedEventsForProfile');
    }
  }

  /// Get user's organized events for profile (not cancelled)
  Future<List<Map<String, dynamic>>> getUserOrganizedEventsForProfile({
    required String userId,
  }) async {
    try {
      final response = await _client.rpc(
        'get_user_organized_events_for_profile',
        params: {'user_id_in': userId},
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e, 'getUserOrganizedEventsForProfile');
    }
  }

  /// Cancel event
  Future<void> cancelEvent({
    required String eventId,
    String? cancellationReason,
  }) async {
    try {
      await _client
          .from(AppConstants.eventsTable)
          .update({
            'is_cancelled': true,
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancellation_reason': cancellationReason,
          })
          .eq('id', eventId);
    } catch (e) {
      throw _handleError(e, 'cancelEvent');
    }
  }

  /// Get single event by ID
  Future<Map<String, dynamic>> getEventById(String eventId) async {
    try {
      final response = await _client
          .from(AppConstants.eventsTable)
          .select()
          .eq('id', eventId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e, 'getEventById');
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
