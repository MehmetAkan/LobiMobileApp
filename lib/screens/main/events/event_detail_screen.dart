import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/event_permission_helper.dart';
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
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_organizer_actions.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_detail_attend_button.dart';
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

  late final bool _isOrganizer;

  @override
  void initState() {
    super.initState();

    _isOrganizer = EventPermissionHelper.isOrganizer(widget.event);

    eventData = _mapEventToDetailData(widget.event);
    _incrementViewCount();
    _loadOrganizerProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Event model'den UI verisi oluştur
  Map<String, dynamic> _mapEventToDetailData(EventModel event) {
    return {
      'id': event.id,
      'title': event.title,
      'coverPhotoUrl': event.imageUrl,
      'organizerName': '',
      'organizerPhotoUrl': null,
      'startDate': event.date,
      'endDate': event.endDate ?? event.date,
      'locationName': event.location,
      'locationAddress': event.locationSecondary ?? '',
      'description': event.description,
    };
  }

  Future<void> _loadOrganizerProfile() async {
    try {
      final organizerId = widget.event.organizerId;

      if (organizerId == null || organizerId.isEmpty) {
        return;
      }

      final profileService = getIt<ProfileService>();
      final ProfileModel? profile = await profileService.getProfile(
        organizerId,
      );

      if (profile == null || !mounted) {
        return;
      }

      setState(() {
        eventData = {
          ...eventData,
          'organizerName': profile.fullName,
          'organizerPhotoUrl': profile.avatarUrl,
        };
      });
    } catch (e) {
      debugPrint('⚠️ Organizer profili yüklenemedi: $e');
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      final eventRepository = getIt<EventRepository>();
      await eventRepository.incrementEventViewCount(widget.event.id);
    } catch (e) {
      debugPrint('⚠️ View count artırılırken hata: $e');
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
                  EventDetailCover(coverPhotoUrl: eventData['coverPhotoUrl']),
                  SizedBox(height: 20.h),
                  EventDetailOrganizer(
                    name: eventData['organizerName'] ?? '',
                    photoUrl: eventData['organizerPhotoUrl'],
                  ),
                  SizedBox(height: 10.h),
                  EventDetailTitle(title: eventData['title'] ?? ''),
                  SizedBox(height: 10.h),
                  EventDetailDate(
                    startDate: eventData['startDate'],
                    endDate: eventData['endDate'],
                  ),
                  SizedBox(height: 25.h),
                  _buildActionButtons(),
                  SizedBox(height: 25.h),
                  const EventDetailSectionTitle(title: 'Konum'),
                  SizedBox(height: 10.h),
                  const EventDetailDivider(),
                  SizedBox(height: 10.h),
                  EventDetailLocation(
                    locationName: eventData['locationName'] ?? '',
                    locationAddress: eventData['locationAddress'] ?? '',
                  ),
                  SizedBox(height: 20.h),
                  const EventDetailSectionTitle(title: 'Açıklama'),
                  SizedBox(height: 10.h),
                  const EventDetailDivider(),
                  SizedBox(height: 10.h),
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
                actions: [if (!_isOrganizer) _buildQuickAttendButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isOrganizer) {
      return EventDetailOrganizerActions(
        onShare: _handleShare,
        onAnnouncement: _handleAnnouncement,
        onManage: _handleManage,
      );
    }

    return EventDetailAttendButton(
      isAttending: false,
      isFull: false,
      onPressed: _handleAttend,
    );
  }

  Widget _buildQuickAttendButton() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _handleAttend,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getAppBarButtonBg(
                  context,
                ).withValues(alpha: 0.5),
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

  void _handleShare() {
    debugPrint('🔗 Paylaş: ${widget.event.id}');
  }

  void _handleAnnouncement() {
    debugPrint('📢 Duyuru: ${widget.event.id}');
  }

  void _handleManage() {
    debugPrint('⚙️ Yönet: ${widget.event.id}');
  }

  void _handleAttend() {
    debugPrint('✅ Katıl: ${widget.event.id}');
  }
}
