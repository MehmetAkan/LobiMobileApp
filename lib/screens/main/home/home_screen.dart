import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/lists/grouped_event_list.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with ScrollablePageMixin {
  DateTime? activeDate;

  /// Yatay liste (mock) - "Beğenebileceğin ve fazlası"
  final List<Map<String, dynamic>> _mockRecommendedEvents = [
    {
      'id': '5',
      'title': 'Morkomedyen Stand Up',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/morkomedyen-stand-up-202492493058dda84e1ba75b43399c3fd34102f70702.jpg',
      'date': '5 Kas - 14:30',
      'location': 'Antalya Açık Hava Tiyartosu',
      'attendeeCount': 500,
    },
    {
      'id': '6',
      'title': 'Ali Congun - Adliye Çayı Stand Up',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/ali-congun-adliye-cayi-stand-up-202581920245282b8a52c40c74b86866b06a02b15a866.jpg',
      'date': '5 Kas - 14:30',
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 200,
    },
    {
      'id': '7',
      'title': 'Türk rock müziğinin efsane grubu Mor ve Ötesi',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/mor-ve-otesi-20259281120578730a00788d4ca0863f88153d521be2.png',
      'date': '5 Kas - 14:30',
      'location': 'Meram Bağları',
      'attendeeCount': 350,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.value; // Şimdilik kullanılmıyor

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController, // Mixin'den geliyor
            padding: EdgeInsets.fromLTRB(
              0.w,
              navbarHeight + 20.h,
              0.w,
              0.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // YATAY LİSTE
                EventsSection(
                  title: 'Beğenebileceğin ve fazlası',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Beğenebileceğin ve fazlası');
                  },
                  child: EventCardList<Map<String, dynamic>>(
                    items: _mockRecommendedEvents,
                    itemBuilder: (event, index) {
                      return EventCardHorizontal(
                        imageUrl: event['imageUrl'] as String,
                        title: event['title'] as String,
                        date: event['date'] as String,
                        location: event['location'] as String,
                        attendeeCount: event['attendeeCount'] as int,
                        isLiked: false,
                        showLikeButton: false,
                        onTap: () {
                          debugPrint(
                            'Etkinliğe tıklandı: ${event['title']}',
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),

                // DİKEY LİSTE - "Bu haftakiler" (GERÇEK VERİ)
                EventsSection(
                  title: 'Bu haftakiler',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Bu haftakiler');
                  },
                  child: _buildThisWeekEvents(navbarHeight),
                ),
              ],
            ),
          ),

          // NAVBAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              scrollController: scrollController,
              leading: (scrolled) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 40.h,
                      width: 40.h,
                      child: SvgPicture.asset(
                        'assets/images/system/lobi-icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear,
                          width: activeDate != null ? 30.w : 45.w,
                          height: activeDate != null ? 25.h : 30.h,
                          child: SvgPicture.asset(
                            'assets/images/system/lobitext.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          layoutBuilder:
                              (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: activeDate == null
                              ? const SizedBox.shrink() // hiçbir şey gösterme
                              : _buildDateContent(context, activeDate!),
                        ),
                      ],
                    ),
                  ],
                );
              },
              actions: (scrolled) => [
                NavbarNotificationButton(
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ana sayfadaki "Bu haftakiler" dikey listesini çizer.
  /// Riverpod provider: [homeThisWeekEventsProvider]
  Widget _buildThisWeekEvents(double navbarHeight) {
    final state = ref.watch(homeThisWeekEventsProvider);

    return state.when(
      loading: () => SizedBox(
        height: 150.h,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('Bu haftakiler yüklenirken hata: $error');

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          child: Text(
            'Etkinlikler yüklenirken bir sorun oluştu.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextDescColor(context),
            ),
          ),
        );
      },
      data: (groups) {
        // EventDayGroup -> GroupedEventList'in beklediği düz Map yapısına çevir
        final List<Map<String, dynamic>> items = [];

        for (final group in groups) {
          for (final event in group.events) {
            final date = event.date;

            final hour =
                date.hour.toString().padLeft(2, '0');
            final minute =
                date.minute.toString().padLeft(2, '0');

            items.add({
              'id': event.id,
              'title': event.title,
              'imageUrl': event.imageUrl,
              // Gruplama için ISO tarih
              'date': date.toIso8601String(),
              // Kart üzerinde gösterilecek metin: sadece saat
              'displayDate': '$hour:$minute',
              'location': event.location,
              'attendeeCount': event.attendeeCount,
              'isLiked': false,
            });
          }
        }

        if (items.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
            child: Text(
              'Bu hafta için etkinlik bulunmuyor.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.getTextDescColor(context),
              ),
            ),
          );
        }

        return GroupedEventList(
          events: items,
          scrollController: scrollController,
          navbarHeight: navbarHeight,
          onActiveDateChanged: (date) {
            setState(() {
              activeDate = date;
            });
          },
        );
      },
    );
  }

  /// Tarih içeriği (activeDate != null iken Navbar'da gösterilen)
  Widget _buildDateContent(BuildContext context, DateTime date) {
    return Row(
      children: [
        Text(
          '${date.day} ${date.monthName}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextHeadColor(context),
            height: 1,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          '/ ${date.dayName}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.getTextDescColor(context),
            height: 1,
          ),
        ),
      ],
    );
  }
}
