import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/connectivity_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Professional offline banner
/// - Auto-hides when online
/// - Dismissable by user
/// - Soft zinc800 background (not aggressive red)
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final networkStatus = ref.watch(connectivityProvider);

    // Reset dismiss when goes offline again
    if (networkStatus == NetworkStatus.offline && _isDismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isDismissed = false);
        }
      });
    }

    // Hide if online or dismissed
    final shouldShow = networkStatus == NetworkStatus.offline && !_isDismissed;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: shouldShow
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.zinc800,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.wifiOff400,
                      color: AppTheme.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'İnternet bağlantısı yok',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isDismissed = true),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          LucideIcons.x400,
                          color: AppTheme.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
