import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_search_button.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/lists/grouped_event_list.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/categories/categories_grid.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with ScrollablePageMixin {
  DateTime? activeDate;
  final List<CategoryModel> _categories = CategoryModel.getMockCategories();
  final List<Map<String, dynamic>> _mockNearbyEvents = [
    {
      'id': '1',
      'title': 'Sillyon Kazıları Gezisi - Antalya Kültür Yolu Festivali',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/sillyon-kazilari-gezisi-antalya-kultur-yolu-festivali-20251017153951c3bb66506bec4586a1c7e94ad06a6949.jpeg',
      'date': '2024-11-05T19:30:00', // ✨ DateTime formatında
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 250,
    },
    {
      'id': '2',
      'title': 'Hayal Satıcısı',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/hayal-saticisi-20259916283672ff27d844264416927c8c68d1fcd571.jpg',
      'date': '2024-11-05T20:00:00', // ✨ Aynı gün
      'location': 'Mevlana Kültür Merkezi',
      'attendeeCount': 180,
    },
    {
      'id': '3',
      'title': 'Tiyatro Oyunu Pioneers Merkezi ',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/merhaba-nietzsche-2025102214543473993bb0f194fecad9ea8f7a73f2d22.jpg',
      'date': '2024-11-06T19:00:00', // ✨ Farklı gün
      'location': 'Konya Şehir Tiyatrosu',
      'attendeeCount': 150,
    },
    {
      'id': '4',
      'title': 'Açık Hava Sineması ',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/b94518d8b24145bfb3b5c41420674c9d.jpg',
      'date': '2024-11-07T21:00:00', // ✨ Farklı gün
      'location': 'Alaaddin Tepesi',
      'attendeeCount': 300,
    },
    {
      'id': '5',
      'title': 'Açık Hava Sineması Pioneers Merkezi',
      'imageUrl': 'https://picsum.photos/id/50/300/300',
      'date': '2024-11-07T21:00:00', // ✨ Farklı gün
      'location': 'Alaaddin Tepesi',
      'attendeeCount': 300,
    },
    {
      'id': '6',
      'title': 'Vitray Cam Boyama Atölyesi',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/vitray-cam-boyama-atolyesi-20251118495902c6a1c22014400a963e54fa24d2aadd.jpg',
      'date': '2024-11-07T21:00:00', // ✨ Farklı gün
      'location': 'Alaaddin Tepesi',
      'attendeeCount': 300,
    },
  ];

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
  final List<Map<String, dynamic>> _mockPopularEvents = [
    {
      'id': '5',
      'title': 'Gelin Takımı Stand Up Gösterisi',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/gelin-takimi-2-20251021161340218bceb06c6540618902e8591c40b1c4.jpg',
      'date': '5 Kas - 14:30',
      'location': 'Antalya Açık Hava Tiyartosu',
      'attendeeCount': 500,
    },
    {
      'id': '6',
      'title': 'Ali Congun - Adliye Çayı Stand Up',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/uykucu-20251022122153ecaef744cab04f40b0a3709e7abe618c.jpg',
      'date': '5 Kas - 14:30',
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 200,
    },
    {
      'id': '7',
      'title': 'Arı Maya Müzikli Danslı İnteraktif Çocuk Oyunu',
      'imageUrl':
          'https://b6s54eznn8xq.merlincdn.net/Uploads/Films/ari-maya-muzikli-dansli-interaktif-cocuk-oyunu-2025113164048015960b03c444a0694afdd08ca695f09.jpeg',
      'date': '5 Kas - 14:30',
      'location': 'Meram Bağları',
      'attendeeCount': 350,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 20.h, 0.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoriesGrid(
                  categories: _categories,
                  onCategoryTap: (category) {
                    debugPrint('Kategori tıklandı: ${category.name}');
                  },
                ),
                SizedBox(height: 25.h),
                EventsSection(
                  title: 'Beğenebileceğin ve fazlası',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Yakındaki Etkinlikler');
                  },
                  child: EventCardList<Map<String, dynamic>>(
                    items: _mockRecommendedEvents,
                    itemBuilder: (event, index) {
                      return EventCardHorizontal(
                        imageUrl: event['imageUrl'],
                        title: event['title'],
                        date: event['date'],
                        location: event['location'],
                        attendeeCount: event['attendeeCount'],
                        isLiked: false,
                        showLikeButton: false,
                        onTap: () {
                          debugPrint('Etkinliğe tıklandı: ${event['title']}');
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 25.h),
                EventsSection(
                  title: 'Popüler olanlar',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Yakındaki Etkinlikler');
                  },
                  child: EventCardList<Map<String, dynamic>>(
                    items: _mockPopularEvents,
                    itemBuilder: (event, index) {
                      return EventCardHorizontal(
                        imageUrl: event['imageUrl'],
                        title: event['title'],
                        date: event['date'],
                        location: event['location'],
                        attendeeCount: event['attendeeCount'],
                        isLiked: false,
                        showLikeButton: false,
                        onTap: () {
                          debugPrint('Etkinliğe tıklandı: ${event['title']}');
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 25.h),
                EventsSection(
                  title: 'Bu haftakiler',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Yakındaki Etkinlikler');
                  },
                  child: GroupedEventList(
                    events: _mockNearbyEvents,
                    scrollController: scrollController,
                    navbarHeight: navbarHeight,
                    onActiveDateChanged: (date) {
                      setState(() {
                        activeDate = date;
                      });
                    },
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
              actions: (scrolled) => [
                Row(
                  children: [
                    NavbarSearchButton(
                      onTap: () {
                        debugPrint('Arama');
                      },
                    ),
                    SizedBox(width: 10.w),
                    NavbarNotificationButton(
                      onTap: () {
                        debugPrint('Bildirimler');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
