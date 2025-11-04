import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/headers/date_header.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';

/// GroupedEventList - Tarihe göre gruplanmış etkinlik listesi
///
/// Özellikler:
/// - Event'leri tarihe göre gruplar
/// - Scroll tracking (navbar için)
/// - DateHeader fade out animasyonu
/// - Herhangi bir sayfada kullanılabilir (reusable)
///
/// Kullanım:
/// ```dart
/// GroupedEventList(
///   events: mockEvents,
///   scrollController: scrollController,
///   navbarHeight: 60.h + statusBarHeight,
///   onActiveDateChanged: (date) {
///     setState(() => activeDate = date);
///   },
/// )
/// ```
class GroupedEventList extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final ScrollController scrollController;
  final double navbarHeight;
  final Function(DateTime?) onActiveDateChanged;
  final EdgeInsetsGeometry? padding;

  const GroupedEventList({
    super.key,
    required this.events,
    required this.scrollController,
    required this.navbarHeight,
    required this.onActiveDateChanged,
    this.padding,
  });

  @override
  State<GroupedEventList> createState() => _GroupedEventListState();
}

class _GroupedEventListState extends State<GroupedEventList> {
  // Her DateHeader için GlobalKey
  final Map<DateTime, GlobalKey> _headerKeys = {};

  // Her DateHeader'ın opacity değeri
  final Map<DateTime, double> _headerOpacities = {};

  // Tarihe göre gruplanmış events
  Map<DateTime, List<Map<String, dynamic>>> _groupedEvents = {};

  @override
  void initState() {
    super.initState();
    _groupEventsByDate();
    _initializeKeys();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  /// Event'leri tarihe göre grupla
  void _groupEventsByDate() {
    _groupedEvents.clear();

    for (var event in widget.events) {
      // Şimdilik mock date kullanıyoruz
      // Gerçek implementasyonda event['date'] kullanılacak
      final date = DateTime.parse(event['date'] ?? DateTime.now().toString());
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (_groupedEvents[dateOnly] == null) {
        _groupedEvents[dateOnly] = [];
      }
      _groupedEvents[dateOnly]!.add(event);
    }

    // Tarihe göre sırala
    _groupedEvents = Map.fromEntries(
      _groupedEvents.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Her DateHeader için GlobalKey oluştur
  void _initializeKeys() {
    for (var date in _groupedEvents.keys) {
      _headerKeys[date] = GlobalKey();
      _headerOpacities[date] = 1.0;
    }
  }

  /// Scroll listener - DateHeader pozisyonlarını kontrol et
  void _onScroll() {
    if (!mounted) return;

    DateTime? newActiveDate;
    bool needsUpdate = false;

    for (var entry in _headerKeys.entries) {
      final date = entry.key;
      final key = entry.value;

      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final headerTop = position.dy;
        final headerBottom = headerTop + renderBox.size.height;

        // DateHeader navbar altına girdi mi?
        if (headerTop <= widget.navbarHeight &&
            headerBottom > widget.navbarHeight) {
          // Fade out miktarını hesapla
          final fadeRange = renderBox.size.height;
          final fadeProgress = (widget.navbarHeight - headerTop) / fadeRange;
          final newOpacity = (1.0 - fadeProgress).clamp(0.0, 1.0);

          if ((_headerOpacities[date] ?? 1.0) != newOpacity) {
            _headerOpacities[date] = newOpacity;
            needsUpdate = true;
          }

          // Bu tarih aktif
          newActiveDate = date;
        }
        // DateHeader navbar'ın üzerinde
        else if (headerTop > widget.navbarHeight) {
          if ((_headerOpacities[date] ?? 1.0) != 1.0) {
            _headerOpacities[date] = 1.0;
            needsUpdate = true;
          }
        }
        // DateHeader tamamen navbar'ın altında
        else if (headerBottom <= widget.navbarHeight) {
          if ((_headerOpacities[date] ?? 1.0) != 0.0) {
            _headerOpacities[date] = 0.0;
            needsUpdate = true;
          }
        }
      }
    }

    // Active date değişti mi?
    widget.onActiveDateChanged(newActiveDate);

    // Opacity değişti mi?
    if (needsUpdate) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _groupedEvents.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      padding: widget.padding ?? EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Parent scroll kullanacak
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = _groupedEvents[date]!;
        final opacity = _headerOpacities[date] ?? 1.0;

        return Column(
          key: _headerKeys[date],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateHeader(date: date, opacity: opacity),
            SizedBox(height: 0.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: events.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  Align(
                    alignment: Alignment
                        .centerRight, // istersen left/right de yapabilirsin
                    child: SizedBox(
                      width: 220.w, // buradan genişliği kontrol ediyorsun
                      child: const Divider(
                        height: 0,
                        thickness: 1,
                        color: AppTheme.zinc300,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
              itemBuilder: (context, eventIndex) {
                final event = events[eventIndex];
                return EventCardVertical(
                  imageUrl: event['imageUrl'],
                  title: event['title'],
                  date: event['date'],
                  location: event['location'],
                  attendeeCount: event['attendeeCount'],
                  isLiked: event['isLiked'] ?? false,
                  showLikeButton: false,
                  onTap: () => debugPrint('Tıklandı: ${event['title']}'),
                );
              },
            ),
            SizedBox(height: 30.h),
          ],
        );
      },
    );
  }
}
