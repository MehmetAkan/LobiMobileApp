import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/core/utils/date_extensions.dart'; // ✨ YENİ

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
         padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            Text(
              '${date.day} ${date.monthName}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextHeadColor(context),
                height: 1,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '/ ${date.dayName}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.getTextDescColor(context),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
