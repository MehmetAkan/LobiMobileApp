import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// AnimatedDateDisplay - Navbar için smooth geçişli tarih göstergesi
/// 
/// Özellikler:
/// - Smooth fade geçişi (AnimatedSwitcher)
/// - Tarih formatı: "5 Kasım / Perşembe"
/// 
/// Kullanım:
/// ```dart
/// AnimatedDateDisplay(
///   date: activeDate,
///   isScrolled: isScrolled,
/// )
/// ```
class AnimatedDateDisplay extends StatelessWidget {
  final DateTime? date;
  final bool isScrolled;

  const AnimatedDateDisplay({
    super.key,
    required this.date,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: date != null
          ? _buildDateContent(context)
          : _buildDefaultContent(context),
    );
  }

  Widget _buildDateContent(BuildContext context) {
    return Row(
      key: ValueKey(date), // AnimatedSwitcher için unique key
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tarih numarası
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.purple900,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            '${date!.day}',
            style: TextStyle(
              fontSize: isScrolled ? 12.sp : 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        
        SizedBox(width: 6.w),
        
        // Ay ve gün
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMonthName(date!.month),
              style: TextStyle(
                fontSize: isScrolled ? 13.sp : 15.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextHeadColor(context),
                height: 1,
              ),
            ),
            Text(
              _getDayName(date!.weekday),
              style: TextStyle(
                fontSize: isScrolled ? 11.sp : 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextDescColor(context),
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultContent(BuildContext context) {
    return Text(
      key: const ValueKey('default'),
      'Etkinlikler',
      style: TextStyle(
        fontSize: isScrolled ? 16.sp : 18.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextHeadColor(context),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    return days[weekday - 1];
  }
}