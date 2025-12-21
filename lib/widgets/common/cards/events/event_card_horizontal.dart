import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';

class EventCardHorizontal extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String location;
  final int attendeeCount;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;

  /// Kart boyutları
  final double? width;
  final double? height;

  /// Stil özellikleri
  final double borderRadius;
  final bool showAttendeeCount;
  final bool showLikeButton;

  const EventCardHorizontal({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.attendeeCount,
    this.isLiked = false,
    this.onTap,
    this.onLikeTap,
    this.width = 200,
    this.height = 150,
    this.borderRadius = 15,
    this.showAttendeeCount = false,
    this.showLikeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width?.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(),
            if (showLikeButton) _buildLikeButton(),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: AppImage(
        path: imageUrl,
        width: width?.w,
        height: height?.h,
        fit: BoxFit.cover,
        placeholder: Container(
          width: width?.w,
          height: height?.h,
          color: AppTheme.zinc200,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Positioned(
      top: 12.h,
      right: 12.w,
      child: GestureDetector(
        onTap: onLikeTap,
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isLiked ? LucideIcons.heart : LucideIcons.heart400,
            size: 20.sp,
            color: isLiked ? AppTheme.red700 : AppTheme.zinc700,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextHeadColor(context),
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.clock400,
                  size: 17.sp,
                  color: AppTheme.getEventIconColor(context),
                ),
                SizedBox(width: 5.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getEventIconTextColor(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.5.h),
            Row(
              children: [
                Icon(
                  LucideIcons.mapPin400,
                  size: 17.sp,
                  color: AppTheme.getEventIconColor(context),
                ),
                SizedBox(width: 6.w),
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
            if (showAttendeeCount) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
