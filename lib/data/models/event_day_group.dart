import 'package:lobi_application/data/models/event_model.dart';

/// Bir güne ait etkinlikleri temsil eden model.
/// 
/// Dikey listelerde (ör: "Bu haftakiler", "Tüm etkinlikler") kullanmak için:
/// - [date] sadece gün bilgisini temsil eder (saat kısmı sıfırlanır)
/// - [events] ilgili güne ait tüm etkinliklerdir.
class EventDayGroup {
  /// Gün (yıl-ay-gün). Saat/dakika/saniye her zaman 00:00:00 olarak normalize edilir.
  final DateTime date;

  /// Bu güne ait etkinlikler. Tarihe (saatine) göre sıralı tutulur.
  final List<EventModel> events;

  const EventDayGroup({
    required this.date,
    required this.events,
  });
}

/// Verilen etkinlik listesini güne göre gruplar.
///
/// Örnek:
///  - 2025-11-05 10:00
///  - 2025-11-05 18:00
///  - 2025-11-06 14:00
///
/// -> 2 adet [EventDayGroup] döner:
///   - 05.11.2025 için 2 etkinlik
///   - 06.11.2025 için 1 etkinlik
List<EventDayGroup> groupEventsByDay(List<EventModel> events) {
  // 1. Tüm event'leri gün bazında grupla
  final Map<DateTime, List<EventModel>> grouped = {};

  for (final event in events) {
    final day = _normalizeDate(event.date);

    if (!grouped.containsKey(day)) {
      grouped[day] = <EventModel>[];
    }
    grouped[day]!.add(event);
  }

  // 2. Günleri kronolojik olarak sırala
  final sortedDates = grouped.keys.toList()
    ..sort((a, b) => a.compareTo(b));

  // 3. Her günün içindeki event'leri de kendi tarihine göre sırala
  final List<EventDayGroup> result = [];

  for (final day in sortedDates) {
    final eventsForDay = List<EventModel>.from(grouped[day]!);
    eventsForDay.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    result.add(
      EventDayGroup(
        date: day,
        events: eventsForDay,
      ),
    );
  }

  return result;
}

/// Bir [DateTime] değerini sadece "yıl-ay-gün" olacak şekilde normalize eder.
///
/// Örn:
///  - 2025-11-05 10:30 -> 2025-11-05 00:00
///  - 2025-11-05 22:15 -> 2025-11-05 00:00
DateTime _normalizeDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
