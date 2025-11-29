import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Local Notification Service
/// Handles displaying notifications when app is in foreground
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.debug('Local notifications already initialized');
      return;
    }

    try {
      AppLogger.info('🔔 Local notifications başlatılıyor...');

      // Android settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // FCM handles this
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      AppLogger.info('✅ Local notifications başlatıldı');
    } catch (e, stackTrace) {
      AppLogger.error('Local notifications başlatma hatası', e, stackTrace);
    }
  }

  /// Show notification from FCM message
  Future<void> showNotificationFromFCM(RemoteMessage message) async {
    if (!_initialized) {
      AppLogger.warning(
        'Local notifications not initialized, skipping display',
      );
      return;
    }

    try {
      final notification = message.notification;
      if (notification == null) {
        AppLogger.debug('FCM message has no notification payload');
        return;
      }

      AppLogger.info('📱 Displaying local notification: ${notification.title}');

      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'lobi_notifications', // channel id
        'Lobi Bildirimleri', // channel name
        channelDescription: 'Lobi uygulama bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notification.hashCode, // notification id
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(), // Pass data for tap handling
      );

      AppLogger.debug('✅ Notification displayed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Show notification error', e, stackTrace);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('🔔 Notification tapped: ${response.payload}');

    // TODO: Navigate to appropriate screen based on payload
    // This can be expanded to parse the payload and navigate
  }

  /// Request permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return result ?? false;
    } catch (e) {
      AppLogger.error('Request permissions error', e);
      return false;
    }
  }
}
