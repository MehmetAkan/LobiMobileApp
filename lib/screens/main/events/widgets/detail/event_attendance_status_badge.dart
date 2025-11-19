import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
import 'package:lobi_application/theme/app_theme.dart';


class EventAttendanceStatusBadge extends StatelessWidget {
  final EventAttendanceStatus status;

  const EventAttendanceStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // notAttending durumunda hiçbir şey gösterme
    if (status == EventAttendanceStatus.notAttending) {
      return const SizedBox.shrink();
    }

    final color = status.getBadgeColor(context);
    final icon = status.iconData;
    final text = status.displayText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17.sp,
            color: AppTheme.white,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}