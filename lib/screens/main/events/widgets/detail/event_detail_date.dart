import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventDetailDate - Tarih bilgisi
/// 
/// Örnek: "Bugün, 17:00 - 21:30"
/// Formatlar için date_extensions.dart kullanılıyor
class EventDetailDate extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const EventDetailDate({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    if (startDate == null || endDate == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Saat ikonu
        Icon(
          LucideIcons.clock400,
          size: 18.sp,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(width: 8.w),

        // Tarih metni
        Text(
          _formatDateRange(startDate!, endDate!),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            height: 1,
          ),
        ),
      ],
    );
  }

  /// Tarih aralığını formatla
  /// Örnek: "Bugün, 17:00 - 21:30" veya "15 Kasım, 14:00 - 18:00"
  String _formatDateRange(DateTime start, DateTime end) {
    // Bugün mü yarın mı kontrol et
    final String dayLabel;
    if (start.isToday) {
      dayLabel = 'Bugün';
    } else if (start.isTomorrow) {
      dayLabel = 'Yarın';
    } else {
      // "15 Kasım" formatı
      dayLabel = '${start.day} ${start.monthName}';
    }

    // Saat formatları
    final startTime = start.toTimeOnly();
    final endTime = end.toTimeOnly();

    return '$dayLabel, $startTime - $endTime';
  }
}