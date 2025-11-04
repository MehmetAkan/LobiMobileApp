import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventCardVertical - Fotoğraf sağda, yazılar solda (Vertical scrolling için)
///
/// Kullanım alanları:
/// - Tüm Etkinlikler Listesi (Alta scroll)
/// - Arama Sonuçları
/// - Kategori Detay Sayfaları
class EventCardVertical extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String location;
  final int attendeeCount;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;

  /// Kart boyutları
  final double? height;

  /// Stil özellikleri
  final double borderRadius;
  final bool showAttendeeCount;
  final bool showLikeButton;

  const EventCardVertical({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.attendeeCount,
    this.isLiked = false,
    this.onTap,
    this.onLikeTap,
    this.height = 120,
    this.borderRadius = 16,
    this.showAttendeeCount = true,
    this.showLikeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol taraf - Resim
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  child: Image.network(
                    imageUrl,
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120.w,
                        height: 120.h,
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
                        width: 130.w,
                        height: 130.h,
                        color: AppTheme.zinc200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius.r),
                          child: Image.network(
                            imageUrl, // Şimdilik aynı resim, sonra organizerLogo olacak
                            width: 15.w,
                            height: 15.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 15.w,
                                height: 15.h,
                                color: AppTheme.zinc300,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'Organizatör', // Şimdilik sabit, sonra parametre olacak
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextDescColor(context),
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
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
                    SizedBox(height: 5.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saat
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
                              date, // Burası saat olacak, şimdilik date
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getEventIconTextColor(context),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // Konum
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
                                  color: AppTheme.getEventIconTextColor(
                                    context,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Katılımcı sayısı
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // if (showAttendeeCount) ...[
                        //   SizedBox(height: 4.h),
                        //   Row(
                        //     children: [
                        //       Icon(
                        //         LucideIcons.users,
                        //         size: 12.sp,
                        //         color: AppTheme.getTextDescColor(context),
                        //       ),
                        //       SizedBox(width: 6.w),
                        //       Text(
                        //         '$attendeeCount kişi',
                        //         style: TextStyle(
                        //           fontSize: 11.sp,
                        //           fontWeight: FontWeight.w500,
                        //           color: AppTheme.getTextDescColor(context),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ],