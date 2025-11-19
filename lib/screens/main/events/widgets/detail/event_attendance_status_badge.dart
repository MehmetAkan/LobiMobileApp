import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventAttendanceStatusBadge - Katılım durumu göstergesi
/// 
/// Tarih bilgisinin hemen altında gösterilir.
/// 
/// Durumlar:
/// - "Katılacaksınız" (yeşil)
/// - "Organizatör Onayı Bekleniyor" (turuncu)
/// - "Katılım Talebiniz Reddedildi" (kırmızı)
/// 
/// Kullanım:
/// ```dart
/// EventAttendanceStatusBadge(
///   status: EventAttendanceStatus.attending,
/// )
/// ```
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
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
            size: 16.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}