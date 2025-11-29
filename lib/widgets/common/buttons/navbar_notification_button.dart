import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/screens/main/notifications/notifications_screen.dart';
import 'package:lobi_application/providers/notification_provider.dart';

class NavbarNotificationButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const NavbarNotificationButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider).value ?? 0;

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
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
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
              top: -2,
              right: -2,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.green900,
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
