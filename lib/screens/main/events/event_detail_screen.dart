import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
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
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:lobi_application/data/services/profile_service.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  late Map<String, dynamic> eventData;

  @override
  void initState() {
    super.initState();
    eventData = _mapEventToDetailData(widget.event);
    _incrementViewCount();
    _loadOrganizerProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Default test verisi
  Map<String, dynamic> _mapEventToDetailData(EventModel event) {
    return {
      'id': event.id,
      'title': event.title,
      'coverPhotoUrl': event.imageUrl,
      // Şimdilik backend’den organizer bilgisi yok
      'organizerName': '',
      'organizerPhotoUrl': null,
      // Şu anda sadece tek bir tarih var, start/end aynı
      'startDate': event.date,
      'endDate': event.endDate ?? event.date,
      'locationName': event.location,
      'locationAddress': event.locationSecondary ?? '',
      'description': event.description,
    };
  }

  Future<void> _loadOrganizerProfile() async {
    try {
      // 1) Artık events tablosuna tekrar sorgu yok
      final organizerId = widget.event.organizerId;

      if (organizerId == null || organizerId.isEmpty) {
        return;
      }

      // 2) organizerId ile profili getir
      final profileService = getIt<ProfileService>();
      final ProfileModel? profile = await profileService.getProfile(
        organizerId,
      );

      if (profile == null || !mounted) {
        return;
      }

      // 3) UI'da organizer alanlarını güncelle
      setState(() {
        eventData = {
          ...eventData,
          'organizerName': profile.fullName,
          'organizerPhotoUrl': profile.avatarUrl,
        };
      });
    } catch (e) {
      debugPrint('Organizer profili yüklenemedi: $e');
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      final eventRepository = getIt<EventRepository>();
      await eventRepository.incrementEventViewCount(widget.event.id);
    } catch (e) {
      // Kullanıcıya hata göstermiyoruz, sadece log atalım
      debugPrint('View count artırılırken hata: $e');
    }
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
            EventBackground(coverPhotoUrl: eventData['coverPhotoUrl']),
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
                  EventDetailCover(coverPhotoUrl: eventData['coverPhotoUrl']),
                  SizedBox(height: 20.h),

                  // 4. Organizatör bilgisi
                  EventDetailOrganizer(
                    name: eventData['organizerName'] ?? '',
                    photoUrl: eventData['organizerPhotoUrl'],
                  ),
                  SizedBox(height: 15.h),

                  // 5. Etkinlik başlığı
                  EventDetailTitle(title: eventData['title'] ?? ''),
                  SizedBox(height: 15.h),

                  // 6. Tarih bilgisi
                  EventDetailDate(
                    startDate: eventData['startDate'],
                    endDate: eventData['endDate'],
                  ),
                  SizedBox(height: 20.h),
                  const EventDetailDivider(),
                  SizedBox(height: 20.h),
                  const EventDetailSectionTitle(title: 'Konum'),
                  SizedBox(height: 15.h),
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
