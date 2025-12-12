import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/providers/notification_provider.dart';
import 'package:lobi_application/data/models/notification_model.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';

/// Notifications Screen
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return StandardPage(
      title: 'Bildirimler',
      children: [
        SizedBox(height: 16.h),
        notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                'Bildirimler yüklenemedi: $error',
                style: TextStyle(color: AppTheme.zinc600, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.bellOff,
                        size: 48.sp,
                        color: AppTheme.zinc400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Henüz bildirim yok',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.zinc700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Yeni bildirimler burada görünecek',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.zinc500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: notifications.map((notification) {
                return _buildNotificationItem(
                  context,
                  ref,
                  notification: notification,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref, {
    required NotificationModel notification,
  }) {
    return InkWell(
      onTap: () async {
        // Mark as read
        if (!notification.isRead) {
          final service = ref.read(notificationServiceProvider);
          await service.markAsRead(notification.id);

          // Invalidate providers to refresh UI
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadNotificationCountProvider);
        }

        // Navigate to event detail if event_id exists
        if (notification.eventId != null && context.mounted) {
          try {
            // Fetch event
            final eventRepository = ref.read(eventRepositoryProvider);
            final event = await eventRepository.getEventById(
              notification.eventId!,
            );

            if (event != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: event),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Etkinlik bulunamadı: $e'),
                  backgroundColor: AppTheme.red600,
                ),
              );
            }
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileAvatar(
                  imageUrl: notification.data?['profile_image_url'] as String?,
                  name: notification.data?['profile_name'] as String? ?? 'User',
                  size: 48.w,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: _getNotificationBadgeColor(notification.type),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.white, width: 2),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      size: 12.sp,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: AppTheme.getNotificationText(context),
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (!notification.isRead) ...[
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppTheme.green500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        _formatTimeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.zinc600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (notification.data?['event_image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  notification.data!['event_image_url'] as String,
                  width: 56.w,
                  height: 56.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56.w,
                      height: 56.w,
                      color: AppTheme.zinc200,
                      child: Icon(
                        LucideIcons.image,
                        color: AppTheme.zinc500,
                        size: 24.sp,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day} ${_getMonthName(dateTime.month)}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return months[month];
  }

  Color _getNotificationBadgeColor(NotificationType type) {
    switch (type) {
      case NotificationType.attendanceApproved:
        return AppTheme.green500;
      case NotificationType.newParticipant:
        return AppTheme.green500;
      case NotificationType.eventReminder:
        return AppTheme.purple900;
      case NotificationType.eventAnnouncement:
        return AppTheme.purple900;
      case NotificationType.eventRejected:
        return AppTheme.red600;
      default:
        return AppTheme.zinc700;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.attendanceApproved:
        return LucideIcons.check;
      case NotificationType.newParticipant:
        return LucideIcons.userPlus;
      case NotificationType.eventReminder:
        return LucideIcons.clock;
      case NotificationType.eventAnnouncement:
        return LucideIcons.megaphone;
      case NotificationType.eventRejected:
        return LucideIcons.x;
      default:
        return LucideIcons.bell;
    }
  }
}
