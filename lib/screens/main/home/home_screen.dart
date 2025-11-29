import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/screens/main/home/widgets/this_week_events_list.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/data/services/fcm_service.dart';
import 'package:lobi_application/widgets/common/modals/notification_permission_modal.dart';
import 'package:lobi_application/core/di/service_locator.dart';

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
            padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 20.h, 0.w, 60.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 0),
                  child: EventsSection(
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
                            debugPrint('Etkinliğe tıklandı: ${event['title']}');
                          },
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 5.h),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: EventsSection(
                    title: 'Bu haftaki etkinlikler',
                    onSeeAll: () {
                      debugPrint('Tümünü gör: Bu haftakiler');
                    },
                    child: _buildThisWeekEvents(navbarHeight),
                  ),
                ),
              ],
            ),
          ),

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
                          layoutBuilder: (currentChild, previousChildren) {
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
              actions: (scrolled) => [const NavbarNotificationButton()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekEvents(double navbarHeight) {
    final state = ref.watch(homeThisWeekEventsProvider);

    return state.when(
      loading: () => SizedBox(
        height: 150.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        debugPrint('Bu haftakiler yüklenirken hata: $error');

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
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
        final List<EventModel> allEvents = [];
        for (final group in groups) {
          allEvents.addAll(group.events);
        }

        if (allEvents.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Text(
              'Bu hafta için etkinlik bulunmuyor.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.getTextDescColor(context),
              ),
            ),
          );
        }

        return ThisWeekEventsList(
          events: allEvents,
          onEventTap: (event) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateContent(BuildContext context, DateTime date) {
    return Row(
      children: [
        Text(
          '${date.day} ${date.monthName}',
          style: AppTextStyles.titleXXSM.copyWith(
            color: AppTheme.getTextHeadColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          '/ ${date.dayName}',
          style: AppTextStyles.titleXXSM.copyWith(
            color: AppTheme.getNavbarDateDescText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
