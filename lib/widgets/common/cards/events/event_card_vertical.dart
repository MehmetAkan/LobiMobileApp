import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';

class EventCardVertical extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date; // Biz bunu saat olarak kullanıyorduk
  final String location;
  final int attendeeCount;
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
    this.isLiked = false,
    this.showLikeButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = 16.r;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.zinc300,
                        child: Icon(
                          LucideIcons.image,
                          size: 32.sp,
                          color: AppTheme.zinc600,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppTheme.red900,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 6,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (showLikeButton)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLiked ? LucideIcons.heart : LucideIcons.heartHandshake,
                      size: 18.sp,
                      color: isLiked ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(context),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        color: AppTheme.zinc300,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'Mehmet Akan', // Şimdilik sabit
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextDescColor(context),
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text("-"),
                    SizedBox(width: 6.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clock3400,
                          size: 16.sp,
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
                  ],
                ),
                SizedBox(height: 5.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.mapPin400,
                          size: 16.sp,
                          color: AppTheme.getEventIconColor(context),
                        ),
                        SizedBox(width: 5.w),
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
          ),
        ],
      ),
    );
  }
}
