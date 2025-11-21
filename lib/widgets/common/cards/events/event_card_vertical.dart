import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';

class EventCardVertical extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date; // Tarih string formatında (ISO 8601)
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
    // Date string'i DateTime'a çevir
    final DateTime? dateTime = DateTime.tryParse(date);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı bilgisi
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: AppImage(
                      path: 'https://i.pravatar.cc/150?u=1',
                      fit: BoxFit.cover,
                      placeholder: Container(color: AppTheme.zinc300),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'Mehmet Akan', // Şimdilik sabit
                  style: AppTextStyles.titleSM.copyWith(
                    color: AppTheme.getTextHeadColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 10.w),

            // Etkinlik görseli
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

            // İçerik kısmı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppTheme.getTextHeadColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                // Tarih ve Saat - İlk satır
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.clock400,
                      size: 16.sp,
                      color: AppTheme.getEventIconColor(context),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      dateTime != null
                          ? dateTime
                                .toShortDateTime() // "5 Kas - 14:30"
                          : date,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getEventIconTextColor(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                // Konum - İkinci satır
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
    );
  }
}
