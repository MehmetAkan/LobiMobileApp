import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventDetailLocation - Konum bilgisi
/// 
/// Konum adı + adres bilgisi
class EventDetailLocation extends StatelessWidget {
  final String locationName;
  final String locationAddress;

  const EventDetailLocation({
    super.key,
    required this.locationName,
    required this.locationAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.getAppBarButtonBg(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.getAppBarButtonBorder(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konum ikonu
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.getAppBarButtonBg(context).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              LucideIcons.mapPin400,
              size: 20.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(width: 12.w),

          // Konum bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konum adı
                Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (locationAddress.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    locationAddress,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}