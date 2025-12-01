import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PopularEventsScreen extends ConsumerWidget {
  const PopularEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularEvents = ref.watch(popularEventsPageProvider);

    return StandardPage(
      title: 'Popüler Etkinlikler',
      children: [
        popularEvents.when(
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(40.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        size: 64.sp,
                        color: AppTheme.zinc400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Henüz popüler etkinlik yok',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.zinc600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 0, bottom: 50),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (_, __) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.zinc200,
                  ),
                ),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCardVertical(
                    imageUrl: event.imageUrl,
                    title: event.title,
                    date: event.date.toIso8601String(),
                    location: event.location,
                    attendeeCount: event.attendeeCount,
                    organizerName: event.organizerName,
                    organizerUsername: event.organizerUsername,
                    organizerPhotoUrl: event.organizerPhotoUrl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: CircularProgressIndicator(color: AppTheme.zinc800),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.triangleAlert,
                    size: 48.sp,
                    color: AppTheme.zinc400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Yüklenirken hata oluştu',
                    style: TextStyle(fontSize: 16.sp, color: AppTheme.zinc600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
