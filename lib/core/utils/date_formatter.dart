
enum DateFormatType {
  /// "5 Kasım Çarşamba"
  long,
  
  /// "5 Kas Çar"
  short,
  
  /// "14:00"
  timeOnly,
  
  /// "5 Kasım - 14:00"
  dateTime,
  
  /// "5 Kas - 14:00"
  shortDateTime,
  
  /// DateHeader için özel format
  headerFormat,
  
  /// "14:00 - 16:30" (başlangıç - bitiş)
  timeRange,
  
  /// Gelecek özellikler için
  relative,      // "2 saat önce"
  todayTomorrow, // "Bugün", "Yarın"
}


class DateFormatter {
  // Private constructor - Utility class
  DateFormatter._();

  /// Ana format metodu
  static String format(
    DateTime date,
    DateFormatType type, {
    DateTime? endDate, // timeRange için
  }) {
    switch (type) {
      case DateFormatType.long:
        return _formatLong(date);
      
      case DateFormatType.short:
        return _formatShort(date);
      
      case DateFormatType.timeOnly:
        return _formatTimeOnly(date);
      
      case DateFormatType.dateTime:
        return _formatDateTime(date);
      
      case DateFormatType.shortDateTime:
        return _formatShortDateTime(date);
      
      case DateFormatType.headerFormat:
        return _formatHeader(date);
      
      case DateFormatType.timeRange:
        if (endDate == null) {
          throw ArgumentError('endDate is required for timeRange format');
        }
        return _formatTimeRange(date, endDate);
      
      case DateFormatType.relative:
        return _formatRelative(date);
      
      case DateFormatType.todayTomorrow:
        return _formatTodayTomorrow(date);
    }
  }

  // ==================== Format Implementation ====================

  /// "5 Kasım Çarşamba"
  static String _formatLong(DateTime date) {
    return '${date.day} ${getMonthName(date.month)} ${getDayName(date.weekday)}';
  }

  /// "5 Kas Çar"
  static String _formatShort(DateTime date) {
    return '${date.day} ${getMonthName(date.month, short: true)} '
        '${getDayName(date.weekday, short: true)}';
  }

  /// "14:00"
  static String _formatTimeOnly(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// "5 Kasım - 14:00"
  static String _formatDateTime(DateTime date) {
    return '${date.day} ${getMonthName(date.month)} - ${_formatTimeOnly(date)}';
  }

  /// "5 Kas - 14:00"
  static String _formatShortDateTime(DateTime date) {
    return '${date.day} ${getMonthName(date.month, short: true)} - '
        '${_formatTimeOnly(date)}';
  }

  /// DateHeader için: "5 Kasım Çarşamba" (şimdilik long ile aynı)
  static String _formatHeader(DateTime date) {
    return _formatLong(date);
  }

  /// "14:00 - 16:30"
  static String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTimeOnly(start)} - ${_formatTimeOnly(end)}';
  }

  /// "2 saat önce" / "3 gün önce" (Gelecek özellik)
  static String _formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// "Bugün" / "Yarın" / "5 Kasım" (Gelecek özellik)
  static String _formatTodayTomorrow(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Bugün';
    } else if (dateOnly == tomorrow) {
      return 'Yarın';
    } else {
      return '${date.day} ${getMonthName(date.month)}';
    }
  }

  static String getMonthName(int month, {bool short = false}) {
    const monthsLong = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    const monthsShort = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    return short ? monthsShort[month - 1] : monthsLong[month - 1];
  }

  /// Gün adını döndür
  /// 
  /// [weekday]: 1-7 arası gün numarası (1: Pazartesi, 7: Pazar)
  /// [short]: true ise kısa format (Pzt), false ise uzun (Pazartesi)
  static String getDayName(int weekday, {bool short = false}) {
    const daysLong = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    
    const daysShort = [
      'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
    ];

    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('Weekday must be between 1 and 7');
    }

    return short ? daysShort[weekday - 1] : daysLong[weekday - 1];
  }

  /// İki tarih aynı gün mü?
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Tarih bugün mü?
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Tarih yarın mı?
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Tarih geçmiş mi?
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Tarih gelecek mi?
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}