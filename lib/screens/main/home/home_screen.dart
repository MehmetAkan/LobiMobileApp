import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with ScrollablePageMixin {
  final List<Map<String, dynamic>> _mockNearbyEvents = [
    {
      'id': '1',
      'title': 'GTC DC: Al Pioneers Cocktai Events',
      'imageUrl': 'https://picsum.photos/id/220/300/300',
      'date': '14 Eki - 19:30 ',
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 250,
    },
    {
      'id': '2',
      'title': 'Stand-up Gösterisi Pioneers Cocktai Salon',
      'imageUrl': 'https://picsum.photos/id/180/300/300',
      'date': '18 Kasım',
      'location': 'Mevlana Kültür Merkezi',
      'attendeeCount': 180,
    },
    {
      'id': '3',
      'title': 'Tiyatro Oyunu Pioneers Merkezi ',
      'imageUrl': 'https://picsum.photos/id/233/300/300',
      'date': '20 Kasım',
      'location': 'Konya Şehir Tiyatrosu',
      'attendeeCount': 150,
    },
    {
      'id': '4',
      'title': 'Açık Hava Sineması',
      'imageUrl': 'https://picsum.photos/id/232/300/300',
      'date': '22 Kasım',
      'location': 'Alaaddin Tepesi',
      'attendeeCount': 300,
    },
  ];

  final List<Map<String, dynamic>> _mockRecommendedEvents = [
    {
      'id': '5',
      'title': 'EDM Festival',
      'imageUrl': 'https://picsum.photos/id/55/300/300',
      'date': '25 Kasım',
      'location': 'Konya Arena',
      'attendeeCount': 500,
    },
    {
      'id': '6',
      'title': 'Klasik Müzik Konseri',
      'imageUrl': 'https://picsum.photos/id/35/300/300',
      'date': '28 Kasım',
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 200,
    },
    {
      'id': '7',
      'title': 'Yemek Festivali',
      'imageUrl': 'https://picsum.photos/id/25/300/300',
      'date': '30 Kasım',
      'location': 'Meram Bağları',
      'attendeeCount': 350,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.value;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/system/other-page-bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.20),
              alignment: Alignment.bottomCenter,
            ),
          ),
          SingleChildScrollView(
            controller: scrollController, // Mixin'den geliyor
            padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 20.h, 0.w, 0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventsSection(
                  title: 'Yakındaki Etkinlikler',
                  onSeeAll: () {
                    debugPrint('Tümünü gör: Yakındaki Etkinlikler');
                  },
                  child: EventCardList<Map<String, dynamic>>(
                    items: _mockNearbyEvents,
                    itemBuilder: (event, index) {
                      return EventCardHorizontal(
                        imageUrl: event['imageUrl'],
                        title: event['title'],
                        date: event['date'],
                        location: event['location'],
                        attendeeCount: event['attendeeCount'],
                        isLiked: false, // Faz 2'de aktif olacak
                        showLikeButton: false, // Şimdilik gizle
                        onTap: () {
                          debugPrint('Etkinliğe tıklandı: ${event['title']}');
                        },
                      );
                    },
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true, 
                  physics:
                      NeverScrollableScrollPhysics(), // Parent scroll kullanacak
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _mockNearbyEvents.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final event = _mockNearbyEvents[index];
                    return EventCardVertical(
                      imageUrl: event['imageUrl'],
                      title: event['title'],
                      date: event['date'],
                      location: event['location'],
                      attendeeCount: event['attendeeCount'],
                      isLiked: false,
                      showLikeButton: false,
                      height: 120.h,
                      onTap: () => debugPrint('Tıklandı: ${event['title']}'),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              scrollController: scrollController, // Mixin'den geliyor
              leading: (scrolled) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isScrolled ? 35.h : 45.h, // Mixin'den geliyor
                    width: isScrolled ? 35.h : 45.h,
                    child: SvgPicture.asset(
                      'assets/images/system/lobi-icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          height: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: isScrolled ? 14.sp : 15.sp,
                          color: AppTheme.getTextDescColor(context),
                        ),
                        child: const Text("Hoş Geldin,"),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          height: 1.2,
                          fontSize: isScrolled ? 16.sp : 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                        child: Text(
                          profile != null
                              ? '${profile.firstName.toUpperCase()} ${profile.lastName.toUpperCase()}'
                              : 'OHH İSMİNİ BULAMADIK',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: (scrolled) => [
                LiquidGlassLayer(
                  child: LiquidGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 60),
                    child: SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60.r),
                          child: Center(
                            child: Icon(
                              LucideIcons.bell400,
                              size: 22.sp,
                              color: AppTheme.getButtonIconColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
