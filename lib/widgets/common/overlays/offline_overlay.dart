import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/connectivity_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full-screen offline overlay for auth screens
/// - Non-dismissable until internet is restored
/// - Auto-hides when online
class OfflineOverlay extends ConsumerWidget {
  const OfflineOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(connectivityProvider);

    if (networkStatus == NetworkStatus.online) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.95),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: AppTheme.zinc800,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.wifiOff400,
                  color: AppTheme.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'İnternet Bağlantısı Yok',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Devam etmek için internet bağlantısı gereklidir.\nBağlantı sağlandığında otomatik devam edilecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.zinc400,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Loading indicator
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.zinc600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
