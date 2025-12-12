import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/screens/main/notifications/notifications_screen.dart';
import 'package:lobi_application/providers/notification_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/data/services/fcm_service.dart';
import 'package:lobi_application/widgets/common/modals/notification_permission_modal.dart';
import 'package:lobi_application/core/di/service_locator.dart';

class NavbarNotificationButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const NavbarNotificationButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;
    final userId = ref.watch(currentUserProfileProvider).value?.userId;

    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap:
                  onTap ??
                  () async {
                    // Check permission before navigating
                    if (userId != null) {
                      final fcmService = getIt<FCMService>();
                      final isGranted = await fcmService.isPermissionGranted();

                      if (!isGranted && context.mounted) {
                        // Show permission modal
                        await fcmService.requestPermissionAndSaveToken(
                          userId: userId,
                          context: context,
                          permissionContext:
                              NotificationPermissionContext.general,
                        );
                      }
                    }

                    // Navigate to notifications screen
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    }
                  },
              customBorder: const CircleBorder(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.getNavbarBtnBg(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getNavbarBtnBorder(context),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.bell,
                    size: 20.sp,
                    color: AppTheme.getButtonIconColor(context),
                  ),
                ),
              ),
            ),
          ),

          // Unread Badge
          if (unreadCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.green600,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
