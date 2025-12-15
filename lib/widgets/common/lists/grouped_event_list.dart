import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';

class GroupedEventList extends StatefulWidget {
  final List<Map<String, dynamic>> events;

  final ScrollController scrollController;
  final double navbarHeight;
  final Function(DateTime?) onActiveDateChanged;
  final EdgeInsetsGeometry? padding;
  final void Function(Map<String, dynamic> event)? onEventTap;

  const GroupedEventList({
    super.key,
    required this.events,
    required this.scrollController,
    required this.navbarHeight,
    required this.onActiveDateChanged,
    this.padding,
    this.onEventTap,
  });

  @override
  State<GroupedEventList> createState() => _GroupedEventListState();
}

class _GroupedEventListState extends State<GroupedEventList> {
  final Map<DateTime, GlobalKey> _headerKeys = {};

  final Map<DateTime, double> _headerOpacities = {};

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

  void _groupEventsByDate() {
    _groupedEvents.clear();

    for (final event in widget.events) {
      final rawDate = event['date'] as String?;
      final date = DateTime.tryParse(rawDate ?? '') ?? DateTime.now();

      final dateOnly = DateTime(date.year, date.month, date.day);

      _groupedEvents.putIfAbsent(dateOnly, () => []);
      _groupedEvents[dateOnly]!.add(event);
    }

    _groupedEvents = Map.fromEntries(
      _groupedEvents.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  void _initializeKeys() {
    for (final date in _groupedEvents.keys) {
      _headerKeys[date] = GlobalKey();
      _headerOpacities[date] = 1.0;
    }
  }

  void _onScroll() {
    if (!mounted) return;

    DateTime? newActiveDate;
    bool needsUpdate = false;

    for (final entry in _headerKeys.entries) {
      final date = entry.key;
      final key = entry.value;

      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final headerTop = position.dy;
        final headerBottom = headerTop + renderBox.size.height;

        if (headerTop <= widget.navbarHeight &&
            headerBottom > widget.navbarHeight) {
          final fadeRange = renderBox.size.height;
          final fadeProgress = (widget.navbarHeight - headerTop) / fadeRange;
          final newOpacity = (1.0 - fadeProgress).clamp(0.0, 1.0) as double;

          if ((_headerOpacities[date] ?? 1.0) != newOpacity) {
            _headerOpacities[date] = newOpacity;
            needsUpdate = true;
          }

          newActiveDate = date;
        } else if (headerTop > widget.navbarHeight) {
          if ((_headerOpacities[date] ?? 1.0) != 1.0) {
            _headerOpacities[date] = 1.0;
            needsUpdate = true;
          }
        } else if (headerBottom <= widget.navbarHeight) {
          if ((_headerOpacities[date] ?? 1.0) != 0.0) {
            _headerOpacities[date] = 0.0;
            needsUpdate = true;
          }
        }
      }
    }

    widget.onActiveDateChanged(newActiveDate);

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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = _groupedEvents[date]!;
        final opacity = _headerOpacities[date] ?? 1.0;

        return Column(
          key: _headerKeys[date],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  SizedBox(height: 20.h),
                  Divider(color: AppTheme.zinc300, thickness: 1, height: 1),
                  SizedBox(height: 20.h),
                ],
              ),
              itemBuilder: (context, eventIndex) {
                final event = events[eventIndex];
                final eventModel = event['eventModel'] as EventModel?;
                if (eventModel == null) {
                  return EventCardVertical(
                    imageUrl: event['imageUrl'] as String? ?? '',
                    title: event['title'] as String? ?? '',
                    date:
                        (event['displayDate'] as String?) ??
                        (event['date'] as String? ?? ''),
                    location: event['location'] as String? ?? '',
                    attendeeCount: (event['attendeeCount'] as int?) ?? 0,
                    isLiked: (event['isLiked'] as bool?) ?? false,
                    showLikeButton: false,
                    onTap: () => debugPrint('Tıklandı: ${event['title']}'),
                  );
                }
                return OpenContainer(
                  transitionDuration: const Duration(milliseconds: 400),
                  transitionType: ContainerTransitionType.fadeThrough,
                  openElevation: 0,
                  closedElevation: 0,
                  openColor: Colors.transparent,
                  closedColor: Colors.transparent,

                  openBuilder: (context, action) {
                    return EventDetailScreen(event: eventModel);
                  },
                  closedBuilder: (context, openContainer) {
                    return EventCardVertical(
                      imageUrl: event['imageUrl'] as String? ?? '',
                      title: event['title'] as String? ?? '',
                      date:
                          (event['displayDate'] as String?) ??
                          (event['date'] as String? ?? ''),
                      location: event['location'] as String? ?? '',
                      attendeeCount: (event['attendeeCount'] as int?) ?? 0,
                      isLiked: (event['isLiked'] as bool?) ?? false,
                      showLikeButton: false,
                      // Kart tıklandığında OpenContainer açsın
                      onTap: openContainer,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Divider(color: AppTheme.zinc300, thickness: 1, height: 1),
            ),
            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }
}
