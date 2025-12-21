import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/widgets/common/modals/notification_permission_modal.dart';
import 'package:lobi_application/data/services/local_notification_service.dart';

/// FCM Service - Firebase Cloud Messaging yönetimi
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _supabase = SupabaseManager.instance.client;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      AppLogger.info('🔥 FCM başlatılıyor...');

      // iOS için permission durumunu kontrol et
      final settings = await _messaging.getNotificationSettings();
      AppLogger.debug('FCM permission status: ${settings.authorizationStatus}');

      // Token al (permission granted olsa bile)
      await _getToken();

      // Message handlers setup
      _setupMessageHandlers();

      AppLogger.info('✅ FCM başlatıldı');
    } catch (e, stackTrace) {
      AppLogger.error('FCM başlatma hatası', e, stackTrace);
    }
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        AppLogger.info('📱 FCM Token (TAM): $_fcmToken');
      } else {
        AppLogger.warning('FCM Token alınamadı (Simulator\'da normal)');
      }

      return _fcmToken;
    } on Exception catch (e) {
      // iOS Simulator'da APNs token hatası normaldir
      if (e.toString().contains('apns-token-not-set')) {
        AppLogger.warning('⚠️ APNs token yok (iOS Simulator - Normal)');
        return null;
      }

      AppLogger.error('FCM token alma hatası', e);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('FCM token alma hatası', e, stackTrace);
      return null;
    }
  }

  /// Request notification permission and save token
  Future<bool> requestPermissionAndSaveToken({
    required String userId,
    BuildContext? context,
    NotificationPermissionContext permissionContext =
        NotificationPermissionContext.general,
  }) async {
    try {
      AppLogger.debug('Bildirim izni isteniyor...');

      // Check current permission status
      final settings = await _messaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('✅ Bildirim izni zaten verilmiş');
        await _saveTokenToProfile(userId);
        return true;
      }

      // iOS'ta kullanıcıya modal göster
      if (context != null) {
        bool? userAccepted;

        // Post-frame callback ile modal göster (build phase hatası önlenir)
        await Future.delayed(Duration.zero);

        final completer = Completer<bool>();

        NotificationPermissionModal.show(
          context,
          permissionContext: permissionContext,
          onAllow: () {
            completer.complete(true);
          },
          onDeny: () {
            completer.complete(false);
          },
        );

        userAccepted = await completer.future;

        if (userAccepted != true) {
          AppLogger.debug('Kullanıcı bildirim iznini reddetti');
          return false;
        }
      }

      // Request permission from system
      final newSettings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isGranted =
          newSettings.authorizationStatus == AuthorizationStatus.authorized;

      if (isGranted) {
        AppLogger.info('✅ Bildirim izni verildi');
        await _getToken();
        await _saveTokenToProfile(userId);
        return true;
      } else {
        AppLogger.warning('Bildirim izni reddedildi');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Bildirim izni isteme hatası', e, stackTrace);
      return false;
    }
  }

  /// Save FCM token to user profile
  Future<void> _saveTokenToProfile(String userId) async {
    try {
      if (_fcmToken == null) {
        AppLogger.warning('FCM token yok, kaydedilemedi');
        return;
      }

      AppLogger.debug('FCM token profile\'a kaydediliyor: $userId');

      // Use upsert instead of update to handle new profiles
      // onConflict ensures existing profiles are updated
      await _supabase.from('profiles').upsert({
        'user_id': userId,
        'fcm_token': _fcmToken,
      }, onConflict: 'user_id');

      AppLogger.info('✅ FCM token kaydedildi');
    } catch (e, stackTrace) {
      AppLogger.error('FCM token kaydetme hatası', e, stackTrace);
      AppLogger.debug('User ID: $userId, Token: $_fcmToken');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info(
        '📩 Foreground mesaj alındı: ${message.notification?.title}',
      );
      _handleMessage(message);
    });

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info(
        '📩 Background mesaj açıldı: ${message.notification?.title}',
      );
      _handleMessageTap(message);
    });

    // App terminated state message tap
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLogger.info(
          '📩 Terminated state mesaj açıldı: ${message.notification?.title}',
        );
        _handleMessageTap(message);
      }
    });

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('🔄 FCM token yenilendi');
      _fcmToken = newToken;
    });
  }

  /// Handle foreground message
  void _handleMessage(RemoteMessage message) {
    AppLogger.info('📩 Foreground notification received');
    AppLogger.debug('Title: ${message.notification?.title}');
    AppLogger.debug('Body: ${message.notification?.body}');
    AppLogger.debug('Data: ${message.data}');

    // Show local notification
    final localNotificationService = LocalNotificationService();
    localNotificationService.showNotificationFromFCM(message);
  }

  /// Handle message tap (navigation)
  void _handleMessageTap(RemoteMessage message) async {
    AppLogger.info('📱 Notification tapped');
    AppLogger.debug('Message data: ${message.data}');

    // Get event_id from notification data
    final eventId = message.data['event_id'] as String?;

    if (eventId == null || eventId.isEmpty) {
      AppLogger.debug('No event_id in notification data');
      return;
    }

    AppLogger.info('Navigating to event from notification: $eventId');

    // Wait a bit for app to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to event detail
    // This requires global navigator key which we'll add to main app
    _navigateToEventDetail(eventId);
  }

  /// Navigate to event detail screen
  void _navigateToEventDetail(String eventId) {
    // Import at top: import 'package:lobi_application/main.dart';
    // Use: navigatorKey.currentState?.push(...)

    // For now, just log - we'll implement global navigation
    AppLogger.info('Event detail navigation: $eventId');
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Delete FCM token from profile (on logout)
  Future<void> deleteTokenFromProfile(String userId) async {
    try {
      AppLogger.debug('FCM token siliniyor: $userId');

      await _supabase
          .from('profiles')
          .update({'fcm_token': null})
          .eq('user_id', userId);

      await _messaging.deleteToken();
      _fcmToken = null;

      AppLogger.info('✅ FCM token silindi');
    } catch (e, stackTrace) {
      AppLogger.error('FCM token silme hatası', e, stackTrace);
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('📩 Background mesaj alındı: ${message.notification?.title}');
}
