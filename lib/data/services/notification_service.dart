import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notification Service - Bildirim CRUD işlemleri
class NotificationService {
  final _supabase = SupabaseManager.instance.client;
  static const String _tableName = 'notifications';

  /// Get user notifications (ordered by created_at desc) with sender profiles
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      AppLogger.debug('Bildirimler getiriliyor: $userId');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notifications = await Future.wait(
        (response as List).map((json) => _enrichNotificationWithProfile(json)),
      );

      AppLogger.info('✅ ${notifications.length} bildirim getirildi');
      return notifications;
    } catch (e, stackTrace) {
      AppLogger.error('Bildirimler getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();

      AppLogger.debug('Okunmamış bildirim sayısı: $response');
      return response.count;
    } catch (e, stackTrace) {
      AppLogger.error('Okunmamış bildirim sayısı hatası', e, stackTrace);
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      AppLogger.debug('Bildirim okundu olarak işaretleniyor: $notificationId');

      await _supabase
          .from(_tableName)
          .update({'is_read': true})
          .eq('id', notificationId);

      AppLogger.info('✅ Bildirim okundu');
    } catch (e, stackTrace) {
      AppLogger.error('Bildirim okundu işaretleme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      AppLogger.debug('Tüm bildirimler okundu olarak işaretleniyor: $userId');

      await _supabase
          .from(_tableName)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      AppLogger.info('✅ Tüm bildirimler okundu');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Tüm bildirimleri okundu işaretleme hatası',
        e,
        stackTrace,
      );
      throw ErrorHandler.handle(e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      AppLogger.debug('Bildirim siliniyor: $notificationId');

      await _supabase.from(_tableName).delete().eq('id', notificationId);

      AppLogger.info('✅ Bildirim silindi');
    } catch (e, stackTrace) {
      AppLogger.error('Bildirim silme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Subscribe to notifications realtime
  Stream<List<NotificationModel>> subscribeToNotifications(String userId) {
    AppLogger.info('🔄 Bildirimlere realtime bağlan ılıyor: $userId');

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          AppLogger.debug('📩 Realtime update alındı: ${data.length} bildirim');

          // Enrich each notification with sender profile
          final notifications = await Future.wait(
            data.map((json) => _enrichNotificationWithProfile(json)),
          );

          return notifications;
        });
  }

  /// Helper: Enrich notification with sender profile
  Future<NotificationModel> _enrichNotificationWithProfile(
    Map<String, dynamic> json,
  ) async {
    var notification = NotificationModel.fromJson(json);

    // Determine sender user ID
    String? senderUserId;

    // If participant_id exists (new_participant notification)
    final participantId = notification.data?['participant_id'] as String?;
    if (participantId != null && participantId.isNotEmpty) {
      senderUserId = participantId;
    }
    // Otherwise, get event organizer
    else if (notification.eventId != null) {
      try {
        final eventResponse = await _supabase
            .from('events')
            .select('organizer_id')
            .eq('id', notification.eventId!)
            .single();

        senderUserId = eventResponse['organizer_id'] as String?;
      } catch (e) {
        AppLogger.debug('Event not found: ${notification.eventId}');
      }
    }

    // Fetch sender profile
    if (senderUserId != null && senderUserId.isNotEmpty) {
      try {
        final profileResponse = await _supabase
            .from('profiles')
            .select('first_name, last_name, avatar_url')
            .eq('user_id', senderUserId)
            .single();

        // Create updated data map
        final updatedData = Map<String, dynamic>.from(notification.data ?? {});

        // Combine first_name and last_name
        final fullName =
            '${profileResponse['first_name']} ${profileResponse['last_name']}';
        updatedData['profile_name'] = fullName;
        updatedData['profile_image_url'] = profileResponse['avatar_url'];

        AppLogger.debug('Sender profile loaded: $fullName');

        notification = notification.copyWith(data: updatedData);
      } catch (e) {
        AppLogger.debug('Sender profile not found: $senderUserId');
      }
    }

    return notification;
  }
}
