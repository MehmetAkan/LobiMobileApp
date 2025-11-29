import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/notification_model.dart';
import 'package:lobi_application/data/services/notification_service.dart';
import 'package:lobi_application/providers/profile_provider.dart';

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return getIt<NotificationService>();
});

/// Notifications Stream Provider
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserProfileProvider).value?.userId;

  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(notificationServiceProvider);
  return service.subscribeToNotifications(userId);
});

/// Unread Count Provider
final unreadNotificationCountProvider = StreamProvider<int>((ref) async* {
  final userId = ref.watch(currentUserProfileProvider).value?.userId;

  if (userId == null) {
    yield 0;
    return;
  }

  final service = ref.watch(notificationServiceProvider);

  // Initial count
  final initialCount = await service.getUnreadCount(userId);
  yield initialCount;

  // Listen to notifications stream and count unread
  await for (final notifications in service.subscribeToNotifications(userId)) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    yield unreadCount;
  }
});
