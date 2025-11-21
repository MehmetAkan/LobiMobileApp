import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';

/// PopularEventsList - Popüler etkinlikler için yatay scroll listesi
///
/// Kullanım: Explore ekranında "Popüler Etkinlikler" bölümü için
class PopularEventsList extends StatelessWidget {
  final List<EventModel> events;
  final double? height;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final void Function(EventModel event)? onEventTap;

  const PopularEventsList({
    super.key,
    required this.events,
    this.height = 240,
    this.spacing = 20,
    this.padding,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: height?.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
        itemCount: events.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing.w),
        itemBuilder: (context, index) {
          final event = events[index];

          final dateText = event.date.toTodayTomorrowWithTime();

          return EventCardHorizontal(
            imageUrl: event.imageUrl,
            title: event.title,
            date: dateText,
            location: event.location,
            attendeeCount: event.attendeeCount,
            isLiked: false,
            showLikeButton: false,
            onTap: () => onEventTap?.call(event),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: height?.h,
      child: Center(
        child: Text(
          'Şu anda popüler etkinlik bulunmuyor.',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
