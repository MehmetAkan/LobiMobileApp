import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventCardCompact extends StatelessWidget {
  final String imageUrl;
  final String title;
  final DateTime date;
  final String location;
  final bool isOrganizer;
  final String? organizerName;
  final String? organizerUsername;
  final String? organizerPhotoUrl;
  final VoidCallback? onTap;

  const EventCardCompact({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    this.isOrganizer = false,
    this.organizerName,
    this.organizerUsername,
    this.organizerPhotoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date text (top) - Format: "25 Kasım / Pazartesi"
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Text(
                  '${date.day} ${date.monthName}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(context),
                  ),
                ),
                Text(
                  ' / ',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  date.dayName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(
                      context,
                    ).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Main card content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoSection(context),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoSection(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return SizedBox(
      width: 160.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                path: imageUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: AppTheme.zinc200,
                  child: Icon(
                    LucideIcons.image,
                    size: 32.sp,
                    color: AppTheme.zinc600,
                  ),
                ),
              ),
            ),
          ),

          if (isOrganizer)
            Positioned(
              bottom: -14.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.purple100,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppTheme.getEventCardOrganizerBorder(context),
                      width: 3.w,
                    ),
                  ),
                  child: Text(
                    'Organizatör',
                    style: TextStyle(
                      fontSize: 13.sp,
                      letterSpacing: -0.25,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.purple900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (organizerName != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                imageUrl: organizerPhotoUrl,
                name: organizerName ?? '',
                size: 25,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organizerName!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1,
                        letterSpacing: -0.25,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                    if (organizerUsername != null)
                      Text(
                        '@$organizerUsername',
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1,
                          letterSpacing: -0.25,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getListUsernameColor(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            letterSpacing: -0.25,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextHeadColor(context),
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              LucideIcons.clock400,
              size: 14.sp,
              color: AppTheme.getEventIconColor(context),
            ),
            SizedBox(width: 4.w),
            Text(
              date.toTimeOnly(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getEventIconTextColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        // Location
        Row(
          children: [
            Icon(
              LucideIcons.mapPin400,
              size: 14.sp,
              color: AppTheme.getEventIconColor(context),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getEventIconTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
