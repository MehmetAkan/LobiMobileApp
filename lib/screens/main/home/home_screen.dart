import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';
import 'package:lobi_application/widgets/common/lists/grouped_event_list.dart';
import 'package:lobi_application/core/utils/date_extensions.dart'; // ✨ YENİ

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with ScrollablePageMixin {
  
  // ✨ YENİ: Aktif tarih state'i (navbar için)
  DateTime? activeDate;

  final List<Map<String, dynamic>> _mockNearbyEvents = [
    {
      'id': '1',
      'title': 'GTC DC: Al Pioneers Cocktai Events',
      'imageUrl': 'https://picsum.photos/id/220/300/300',
      'date': '2024-11-05T19:30:00', // ✨ DateTime formatında
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 250,
    },
    {
      'id': '2',
      'title': 'Stand-up Gösterisi Pioneers Cocktai Salon',
      'imageUrl': 'https://picsum.photos/id/180/300/300',
      'date': '2024-11-05T20:00:00', // ✨ Aynı gün
      'location': 'Mevlana Kültür Merkezi',
      'attendeeCount': 180,
    },
    {
      'id': '3',
      'title': 'Tiyatro Oyunu Pioneers Merkezi ',
      'imageUrl': 'https://picsum.photos/id/233/300/300',
      'date': '2024-11-06T19:00:00', // ✨ Farklı gün
      'location': 'Konya Şehir Tiyatrosu',
      'attendeeCount': 150,
    },
    {
      'id': '4',
      'title': 'Açık Hava Sineması',
      'imageUrl': 'https://picsum.photos/id/232/300/300',
      'date': '2024-11-07T21:00:00', // ✨ Farklı gün
      'location': 'Alaaddin Tepesi',
      'attendeeCount': 300,
    },
  ];

  final List<Map<String, dynamic>> _mockRecommendedEvents = [
    {
      'id': '5',
      'title': 'EDM Festival',
      'imageUrl': 'https://picsum.photos/id/55/300/300',
      'date': '2024-11-25T22:00:00',
      'location': 'Konya Arena',
      'attendeeCount': 500,
    },
    {
      'id': '6',
      'title': 'Klasik Müzik Konseri',
      'imageUrl': 'https://picsum.photos/id/35/300/300',
      'date': '2024-11-28T19:00:00',
      'location': 'Konya Kültür Merkezi',
      'attendeeCount': 200,
    },
    {
      'id': '7',
      'title': 'Yemek Festivali',
      'imageUrl': 'https://picsum.photos/id/25/300/300',
      'date': '2024-11-30T12:00:00',
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
                // Yatay scroll olan etkinlikler (değişiklik yok)
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
                        isLiked: false,
                        showLikeButton: false,
                        onTap: () {
                          debugPrint('Etkinliğe tıklandı: ${event['title']}');
                        },
                      );
                    },
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // ✨ YENİ: Tarihe göre gruplanmış dikey liste
                GroupedEventList(
                  events: _mockNearbyEvents,
                  scrollController: scrollController,
                  navbarHeight: navbarHeight,
                  onActiveDateChanged: (date) {
                    setState(() {
                      activeDate = date;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              scrollController: scrollController,
              
              // ✨ GÜNCELLEME: Leading kısmı - Logo her zaman görünür, text değişir
              leading: (scrolled) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo - HER ZAMAN GÖRÜNÜR
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isScrolled ? 35.h : 45.h,
                      width: isScrolled ? 35.h : 45.h,
                      child: SvgPicture.asset(
                        'assets/images/system/lobi-icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    SizedBox(width: 5.w),
                    
                    // Text kısmı - DEĞIŞKEN (Hoş Geldin / Tarih)
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
                          alignment: Alignment.centerLeft, // ✨ Sol hizalı
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: activeDate != null
                          ? _buildDateContent(context, activeDate!)
                          : _buildWelcomeContent(context, profile),
                    ),
                  ],
                );
              },
              
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

  /// Tarih içeriği (activeDate != null iken)
  Widget _buildDateContent(BuildContext context, DateTime date) {
    return Column(
      key: ValueKey('date_${date.day}_${date.month}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          date.monthName, // ✨ Extension kullanımı
          style: TextStyle(
            fontSize: isScrolled ? 13.sp : 15.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextHeadColor(context),
            height: 1,
          ),
        ),
        Text(
          date.dayName, // ✨ Extension kullanımı
          style: TextStyle(
            fontSize: isScrolled ? 11.sp : 12.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextDescColor(context),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Hoş geldin içeriği (activeDate == null iken)
  Widget _buildWelcomeContent(BuildContext context, dynamic profile) {
    return Column(
      key: const ValueKey('welcome'),
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
    );
  }

}