import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';
import 'package:lobi_application/theme/app_theme.dart';

class ThisWeekEventsList extends StatelessWidget {
  final List<EventModel> events;
  final EdgeInsetsGeometry? padding;
  final void Function(EventModel event)? onEventTap;

  const ThisWeekEventsList({
    super.key,
    required this.events,
    this.padding,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      itemCount: events.length,
      separatorBuilder: (context, index) {
        if (index == events.length - 1) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Divider(color: AppTheme.zinc300, thickness: 1, height: 1),
            ),
            SizedBox(height: 20.h),
          ],
        );
      },
      itemBuilder: (context, index) {
        final event = events[index];
        final dateText = event.date.toTodayTomorrowWithTime();
        return EventCardVertical(
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Center(
        child: Text(
          'Bu hafta için etkinlik bulunmuyor.',
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
