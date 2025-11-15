import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailSectionTitle - Bölüm başlıkları
/// 
/// CreateEventScreen'deki "Biletlendirme" başlığı ile aynı stil
/// Örnek: "Konum", "Açıklama"
class EventDetailSectionTitle extends StatelessWidget {
  final String title;

  const EventDetailSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.white,
        height: 1,
      ),
    );
  }
}