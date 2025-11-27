import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';

class EventCardVertical extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date; // Tarih string formatında (ISO 8601)
  final String location;
  final int attendeeCount;
  final String? organizerName;
  final String? organizerUsername;
  final String? organizerPhotoUrl;
  final bool isLiked;
  final bool showLikeButton;
  final VoidCallback? onTap;

  const EventCardVertical({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.attendeeCount,
    this.organizerName,
    this.organizerUsername,
    this.organizerPhotoUrl,
    this.isLiked = false,
    this.showLikeButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Date string'i DateTime'a çevir
    final DateTime? dateTime = DateTime.tryParse(date);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                imageUrl: organizerPhotoUrl,
                name: organizerName ?? '',
                size: 30,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organizerName ?? 'Unknown',
                      style: AppTextStyles.titleSM.copyWith(
                        color: AppTheme.getTextHeadColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (organizerUsername != null)
                      Text(
                        '@$organizerUsername',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.zinc600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: AppImage(
                path: imageUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: AppTheme.zinc300,
                  child: Icon(
                    LucideIcons.image,
                    size: 32.sp,
                    color: AppTheme.zinc600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppTheme.getTextHeadColor(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    dateTime != null ? dateTime.toShortDateTime() : date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getEventIconTextColor(context),
                    ),
                  ),
                  SizedBox(width: 5.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.zinc500,
                      shape: BoxShape.circle,
                    ),
                    height: 5.h,
                    width: 5.h,
                  ),
                  SizedBox(width: 5.h),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 14.sp,
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
          ),
        ],
      ),
    );
  }
}
