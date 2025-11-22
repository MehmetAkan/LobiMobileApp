import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventAttendeeActionDropdown extends StatelessWidget {
  final VoidCallback onCancelAttendance;

  const EventAttendeeActionDropdown({
    super.key,
    required this.onCancelAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppTheme.white.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 8,
      offset: Offset(0, -60.h),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                LucideIcons.calendarPlus400,
                size: 20.sp,
                color: AppTheme.black800,
              ),
              SizedBox(width: 12.w),
              Text(
                'Takvime Ekle',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black800,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'cancel',
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(LucideIcons.userX400, size: 20.sp, color: AppTheme.red900),
              SizedBox(width: 12.w),
              Text(
                'Katılımı İptal Et',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red900,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'cancel') {
          onCancelAttendance();
        }
      },
      child: Container(
        height: 55.h,
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.ellipsis400, size: 18.sp, color: AppTheme.white),
            SizedBox(height: 4.w),
            Text(
              'Daha Fazla',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
