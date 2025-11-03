import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// DateHeader - Tarihe göre gruplanmış listelerde kullanılan başlık
/// 
/// Özellikler:
/// - Tarih gösterimi: "5 Kasım / Çarşamba"
/// - Fade out animasyonu için opacity desteği
/// - Herhangi bir sayfada kullanılabilir (reusable)
/// 
/// Kullanım:
/// ```dart
/// DateHeader(
///   date: DateTime(2024, 11, 5),
///   opacity: 1.0, // 0.0 - 1.0 arası
/// )
/// ```
class DateHeader extends StatelessWidget {
  final DateTime date;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  const DateHeader({
    super.key,
    required this.date,
    this.opacity = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            // Tarih numarası (kutucuk içinde)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.purple900,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            
            SizedBox(width: 10.w),
            
            // Ay ve gün adı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMonthName(date.month),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(context),
                    height: 1,
                  ),
                ),
                Text(
                  _getDayName(date.weekday),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextDescColor(context),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Ay adını döndür
  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  /// Gün adını döndür
  String _getDayName(int weekday) {
    const days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    return days[weekday - 1];
  }
}