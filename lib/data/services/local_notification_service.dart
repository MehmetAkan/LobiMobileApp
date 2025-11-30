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
  void _onNotificationTapped(NotificationResponse response) async {
    AppLogger.info('🔔 Notification tapped: ${response.payload}');

    if (response.payload == null) return;

    try {
      // Parse payload to get notification data
      // Payload format: "{notification_id: xxx, event_id: xxx, type: xxx}"
      final payload = response.payload!;

      // Extract event_id from payload
      final eventIdMatch = RegExp(r'event_id:\s*([^,}]+)').firstMatch(payload);
      if (eventIdMatch == null) {
        AppLogger.debug('No event_id in payload');
        return;
      }

      final eventId = eventIdMatch.group(1)?.trim();
      if (eventId == null || eventId.isEmpty) return;

      AppLogger.info('Navigating to event: $eventId');

      // Navigate using the app's global navigator
      // This will be handled by MainApp's navigatorKey
      _navigateToEvent(eventId);
    } catch (e, stackTrace) {
      AppLogger.error('Notification tap handler error', e, stackTrace);
    }
  }

  /// Navigate to event detail (to be implemented with global navigator)
  void _navigateToEvent(String eventId) {
    // This will navigate when app is opened from notification
    // The actual navigation is handled by FCM message tap handler
    AppLogger.info('Event navigation queued: $eventId');
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
