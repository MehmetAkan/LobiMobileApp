import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/screens/main/events/widgets/global/event_background.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_cover.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_organizer.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_title.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_date.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_section_title.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_location.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_divider.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_description.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailScreen - Etkinlik detay sayfası
/// 
/// Özellikler:
/// - OpenContainer ile açılır (karttan büyüyerek)
/// - CreateEventScreen ile aynı background ve navbar yapısı
/// - Bölüm bölüm ayrılmış widget yapısı
/// 
/// Test verisi ile çalışır, sonraki aşamada Supabase entegrasyonu yapılacak
class EventDetailScreen extends StatefulWidget {
  // Şimdilik test verisi alıyoruz, sonra event ID ile çalışacak
  final Map<String, dynamic>? testEventData;

  const EventDetailScreen({
    super.key,
    this.testEventData,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  // Test verisi
  late Map<String, dynamic> eventData;

  @override
  void initState() {
    super.initState();
    
    // Test verisi - Gerçek veri gelmezse default kullan
    eventData = widget.testEventData ?? _getDefaultTestData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Default test verisi
  Map<String, dynamic> _getDefaultTestData() {
    return {
      'id': 'test-event-1',
      'title': 'Flutter & Firebase ile Mobil Uygulama Geliştirme',
      'coverPhotoUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      'organizerName': 'Ahmet Yılmaz',
      'organizerPhotoUrl': 'https://i.pravatar.cc/150?img=12',
      'startDate': DateTime.now().add(const Duration(days: 2, hours: 5)),
      'endDate': DateTime.now().add(const Duration(days: 2, hours: 8)),
      'locationName': 'Bilge Adam Teknoloji',
      'locationAddress': 'Maslak, Sarıyer / İstanbul',
      'description': 'Bu workshopta Flutter framework\'ü ile modern mobil uygulamalar geliştirmeyi öğreneceksiniz. Firebase entegrasyonu, state management ve UI/UX best practice\'lerini uygulamalı olarak deneyimleyeceksiniz.\n\nKatılımcılar:\n• Flutter temellerini öğrenecek\n• Firebase authentication kullanacak\n• Riverpod ile state management yapacak\n• Gerçek bir proje geliştirecek',
      'attendeeCount': 42,
      'capacity': 50,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.h + statusBarHeight;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            // 1. Arka plan (Cover photo blur)
            EventBackground(coverPhotoUrl: eventData['coverPhotoUrl']),

            // 2. Scrollable içerik
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                20.w,
                appBarHeight + 20.h,
                20.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Cover fotoğraf
                  EventDetailCover(
                    coverPhotoUrl: eventData['coverPhotoUrl'],
                  ),
                  SizedBox(height: 20.h),

                  // 4. Organizatör bilgisi
                  EventDetailOrganizer(
                    name: eventData['organizerName'] ?? '',
                    photoUrl: eventData['organizerPhotoUrl'],
                  ),
                  SizedBox(height: 15.h),

                  // 5. Etkinlik başlığı
                  EventDetailTitle(
                    title: eventData['title'] ?? '',
                  ),
                  SizedBox(height: 15.h),

                  // 6. Tarih bilgisi
                  EventDetailDate(
                    startDate: eventData['startDate'],
                    endDate: eventData['endDate'],
                  ),
                  SizedBox(height: 25.h),

                  // 7. "Konum" başlığı
                  const EventDetailSectionTitle(title: 'Konum'),
                  SizedBox(height: 12.h),

                  // Konum bilgisi
                  EventDetailLocation(
                    locationName: eventData['locationName'] ?? '',
                    locationAddress: eventData['locationAddress'] ?? '',
                  ),
                  SizedBox(height: 20.h),

                  // 8. Divider
                  const EventDetailDivider(),
                  SizedBox(height: 20.h),

                  // 9. "Açıklama" başlığı
                  const EventDetailSectionTitle(title: 'Açıklama'),
                  SizedBox(height: 12.h),

                  // 10. Açıklama içeriği
                  EventDetailDescription(
                    description: eventData['description'] ?? '',
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),

            // Navbar (en üstte)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FullPageAppBar(
                title: eventData['title'] ?? 'Etkinlik Detayı',
                scrollController: _scrollController,
                style: AppBarStyle.dark,
                actions: [_buildRegisterButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sağ üstteki "Kayıt Ol" butonu
  Widget _buildRegisterButton() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              // TODO: Kayıt ol işlemi
              debugPrint('Kayıt ol butonuna tıklandı');
            },
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getAppBarButtonBg(context).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getAppBarButtonBorder(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.userPlus400,
                  size: 22.sp,
                  color: AppTheme.getAppBarButtonColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}