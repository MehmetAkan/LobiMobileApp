import 'package:lobi_application/core/utils/date_formatter.dart';
/// DateTime Extension - Kolay kullanım için shortcut'lar
/// 
/// Kullanım:
/// ```dart
/// final date = DateTime.now();
/// 
/// // Format shortcut'ları
/// print(date.toLongFormat());        // "5 Kasım Çarşamba"
/// print(date.toShortFormat());       // "5 Kas Çar"
/// print(date.toTimeOnly());          // "14:00"
/// print(date.toDateTime());          // "5 Kasım - 14:00"
/// 
/// // Helper'lar
/// if (date.isToday) {
///   print('Bu etkinlik bugün!');
/// }
/// ```
extension DateTimeFormatting on DateTime {
  // ==================== Format Shortcut'ları ====================

  /// "5 Kasım Çarşamba"
  String toLongFormat() {
    return DateFormatter.format(this, DateFormatType.long);
  }

  /// "5 Kas Çar"
  String toShortFormat() {
    return DateFormatter.format(this, DateFormatType.short);
  }

  /// "14:00"
  String toTimeOnly() {
    return DateFormatter.format(this, DateFormatType.timeOnly);
  }

  /// "5 Kasım - 14:00"
  String toDateTime() {
    return DateFormatter.format(this, DateFormatType.dateTime);
  }

  /// "5 Kas - 14:00"
  String toShortDateTime() {
    return DateFormatter.format(this, DateFormatType.shortDateTime);
  }

  /// DateHeader formatı
  String toHeaderFormat() {
    return DateFormatter.format(this, DateFormatType.headerFormat);
  }

  /// "14:00 - 16:30" (başlangıç - bitiş)
  String toTimeRange(DateTime endDate) {
    return DateFormatter.format(
      this,
      DateFormatType.timeRange,
      endDate: endDate,
    );
  }

  /// "2 saat önce" / "3 gün önce"
  String toRelative() {
    return DateFormatter.format(this, DateFormatType.relative);
  }

  /// "Bugün" / "Yarın" / "5 Kasım"
  String toTodayTomorrow() {
    return DateFormatter.format(this, DateFormatType.todayTomorrow);
  }

  // ==================== Helper Getter'lar ====================

  /// Ay adı - Uzun format
  String get monthName {
    return DateFormatter.getMonthName(month);
  }

  /// Ay adı - Kısa format
  String get monthNameShort {
    return DateFormatter.getMonthName(month, short: true);
  }

  /// Gün adı - Uzun format
  String get dayName {
    return DateFormatter.getDayName(weekday);
  }

  /// Gün adı - Kısa format
  String get dayNameShort {
    return DateFormatter.getDayName(weekday, short: true);
  }

  /// Sadece tarih kısmı (saat olmadan)
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  // ==================== Boolean Helper'lar ====================

  /// Bu tarih bugün mü?
  bool get isToday {
    return DateFormatter.isToday(this);
  }

  /// Bu tarih yarın mı?
  bool get isTomorrow {
    return DateFormatter.isTomorrow(this);
  }

  /// Bu tarih geçmiş mi?
  bool get isPast {
    return DateFormatter.isPast(this);
  }

  /// Bu tarih gelecek mi?
  bool get isFuture {
    return DateFormatter.isFuture(this);
  }

  /// Bu tarih verilen tarih ile aynı gün mü?
  bool isSameDayAs(DateTime other) {
    return DateFormatter.isSameDay(this, other);
  }

  // ==================== Karşılaştırma Helper'ları ====================

  /// Bu hafta içinde mi?
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return isAfter(weekStart) && isBefore(weekEnd);
  }

  /// Bu ay içinde mi?
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Bu yıl içinde mi?
  bool get isThisYear {
    return year == DateTime.now().year;
  }
}

/// Duration Extension - Süre formatlaması
/// 
/// Kullanım:
/// ```dart
/// final duration = Duration(hours: 2, minutes: 30);
/// print(duration.toReadableString()); // "2 saat 30 dakika"
/// ```
extension DurationFormatting on Duration {
  /// "2 saat 30 dakika" formatında
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours saat $minutes dakika';
    } else if (hours > 0) {
      return '$hours saat';
    } else if (minutes > 0) {
      return '$minutes dakika';
    } else {
      return 'Az önce';
    }
  }

  /// "2s 30d" kısa format
  String toShortString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}s ${minutes}d';
    } else if (hours > 0) {
      return '${hours}s';
    } else if (minutes > 0) {
      return '${minutes}d';
    } else {
      return '0d';
    }
  }
}