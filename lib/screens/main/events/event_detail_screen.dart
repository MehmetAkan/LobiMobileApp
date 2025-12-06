import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
import 'package:lobi_application/data/models/event_attendance_model.dart';
import 'package:lobi_application/data/services/event_attendance_service.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/screens/main/events/manage/event_manage_screen.dart';
import 'package:lobi_application/screens/main/events/manage/event_manage_requests_screen.dart';
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
import 'package:lobi_application/screens/main/events/widgets/detail/event_attendance_status_badge.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_attendee_action_buttons.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/event_pending_approval_button.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_cancel_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/screens/main/events/widgets/detail/qr_ticket_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/data/services/share_service.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final EventAttendanceService _attendanceService = EventAttendanceService();
  final EventRepository _eventRepository = getIt<EventRepository>();

  late Map<String, dynamic> eventData;
  late final bool _isOrganizer;
  late EventModel _currentEvent; // Current event (might be refreshed)

  EventAttendanceStatus _attendanceStatus = EventAttendanceStatus.notAttending;
  bool _isLoadingAttendance = true;
  bool _isProcessingAttendance = false;

  @override
  void initState() {
    super.initState();

    _currentEvent = widget.event; // Initialize with initial event
    _isOrganizer = _checkIsOrganizer();

    eventData = _mapEventToDetailData(_currentEvent);
    _incrementViewCount();
    _loadOrganizerProfile();

    if (!_isOrganizer) {
      _loadAttendanceStatus();
    } else {
      _isLoadingAttendance = false;
    }
  }

  bool _checkIsOrganizer() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final eventOrganizerId = widget.event.organizerId;

    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }

    if (eventOrganizerId == null || eventOrganizerId.isEmpty) {
      return false;
    }

    return currentUserId.trim() == eventOrganizerId.trim();
  }

  Future<void> _loadAttendanceStatus() async {
    setState(() => _isLoadingAttendance = true);

    try {
      final status = await _attendanceService.getAttendanceStatus(
        eventId: widget.event.id,
      );

      if (mounted) {
        setState(() {
          _attendanceStatus = status;
          _isLoadingAttendance = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Katılım durumu yüklenemedi: $e');
      if (mounted) {
        setState(() => _isLoadingAttendance = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Refresh event data from backend
  Future<void> _refreshEvent() async {
    try {
      final updatedEvent = await _eventRepository.getEventById(widget.event.id);

      if (mounted) {
        setState(() {
          _currentEvent = updatedEvent;
          eventData = _mapEventToDetailData(_currentEvent);
        });

        // Invalidate event providers to refresh Home/Explore lists
        ref.invalidate(homeThisWeekEventsProvider);
        ref.invalidate(discoverPopularEventsProvider);
        ref.invalidate(
          discoverEventsControllerProvider,
        ); // Explore upcoming events

        getIt<AppFeedbackService>().showSuccess(
          'Etkinlik bilgileri güncellendi',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Event refresh error: $e');
      if (mounted) {
        getIt<AppFeedbackService>().showError('Güncellenmiş veri alınamadı');
      }
    }
  }

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
                appBarHeight + 10.h,
                20.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EventDetailOrganizer(
                        name: eventData['organizerName'] ?? '',
                        photoUrl: eventData['organizerPhotoUrl'],
                      ),
                      if (_isOrganizer) ...[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: AppTheme.purple100,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            child: Text(
                              "Organizatör",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.purple900,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 10.h),
                  EventDetailCover(coverPhotoUrl: eventData['coverPhotoUrl']),

                  // Cancelled event banner
                  if (_currentEvent.isCancelled) ...[
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: AppTheme.red800,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.circleX,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Bu Etkinlik İptal Edilmiştir',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 10.h),
                  if (!_isOrganizer && !_isLoadingAttendance) ...[
                    SizedBox(height: 10.h),
                    EventAttendanceStatusBadge(status: _attendanceStatus),
                  ],
                  SizedBox(height: 10.h),
                  EventDetailTitle(title: eventData['title'] ?? ''),
                  SizedBox(height: 10.h),
                  EventDetailDate(
                    startDate: eventData['startDate'],
                    endDate: eventData['endDate'],
                  ),

                  SizedBox(height: 20.h),
                  _buildActionButtons(),
                  SizedBox(height: 20.h),
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
                actions: [
                  if (!_isOrganizer && !_attendanceStatus.canLeaveEvent)
                    _buildQuickAttendButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Return empty if cancelled
    if (_currentEvent.isCancelled) {
      return const SizedBox.shrink();
    }

    if (_isOrganizer) {
      return EventDetailOrganizerActions(
        onShare: _handleShare,
        onAnnouncement: _handleAnnouncement,
        onRequests: _handleViewRequests, // Fixed method name
        showRequests:
            widget.event.requiresApproval ==
            true, // Only show if requires approval
        onManage: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventManageScreen(event: _currentEvent),
            ),
          );

          // If update successful, refresh event data
          if (result == true && mounted) {
            await _refreshEvent();
          }
        },
      );
    }

    if (_isLoadingAttendance) {
      return Center(child: CircularProgressIndicator(color: AppTheme.white));
    }

    // Pending approval durumunda özel buton göster
    if (_attendanceStatus == EventAttendanceStatus.pending) {
      return EventPendingApprovalButton(
        onCancelConfirmed: _handleCancelAttendance,
      );
    }

    // Attending durumunda normal action butonlar
    if (_attendanceStatus.canLeaveEvent) {
      return EventAttendeeActionButtons(
        onTicket: _handleTicket,
        onContact: _handleContact,
        onCancelAttendance: _handleCancelAttendance,
      );
    }

    // Attended veya DidNotAttend durumunda hiçbir buton gösterme
    if (_attendanceStatus == EventAttendanceStatus.attended ||
        _attendanceStatus == EventAttendanceStatus.didNotAttend) {
      return const SizedBox.shrink();
    }

    return EventDetailAttendButton(
      isAttending: false,
      isFull: false,
      onPressed: _isProcessingAttendance ? () {} : _handleAttend,
    );
  }

  Widget _buildQuickAttendButton() {
    // Hide if event is cancelled
    if (_currentEvent.isCancelled) {
      return const SizedBox.shrink();
    }

    // Attended veya DidNotAttend durumunda butonu gizle
    if (_attendanceStatus == EventAttendanceStatus.attended ||
        _attendanceStatus == EventAttendanceStatus.didNotAttend) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _isProcessingAttendance ? null : _handleAttend,
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
                child: _isProcessingAttendance
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.getAppBarButtonColor(context),
                        ),
                      )
                    : Icon(
                        LucideIcons.ticket400,
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

  void _handleShare() async {
    try {
      final shareService = ShareService();
      await shareService.shareEvent(_currentEvent);
    } catch (e) {
      debugPrint('⚠️ Share error: $e');
      if (mounted) {
        getIt<AppFeedbackService>().showError('Paylaşım başarısız');
      }
    }
  }

  void _handleAnnouncement() {
    debugPrint('📢 Duyuru: ${widget.event.id}');
  }

  void _handleViewRequests() {
    // Only show requests if event requires approval
    if (widget.event.requiresApproval == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EventManageRequestsScreen(eventId: widget.event.id),
        ),
      );
    }
  }

  void _handleManage() {
    debugPrint('⚙️ Yönet: ${widget.event.id}');
  }

  Future<void> _handleAttend() async {
    if (_isProcessingAttendance) return;

    setState(() => _isProcessingAttendance = true);

    try {
      final requiresApproval = widget.event.requiresApproval;

      debugPrint('✅ Katıl işlemi başlatıldı');
      debugPrint('   Event ID: ${widget.event.id}');
      debugPrint('   Onay gerekli: $requiresApproval');

      final newStatus = await _attendanceService.attendEvent(
        eventId: widget.event.id,
        requiresApproval: requiresApproval,
      );

      if (!mounted) return;

      setState(() {
        _attendanceStatus = newStatus;
        _isProcessingAttendance = false;
      });

      final message = requiresApproval
          ? 'Katılım talebiniz gönderildi.'
          : 'Etkinliğe katıldınız';

      if (requiresApproval) {
        getIt<AppFeedbackService>().showSuccess(message);
      } else {
        getIt<AppFeedbackService>().showSuccess(message);
      }
    } catch (e) {
      debugPrint('⚠️ Katılım hatası: $e');

      if (!mounted) return;

      setState(() => _isProcessingAttendance = false);

      getIt<AppFeedbackService>().showError('Katılım işlemi başarısız: $e');
    }
  }

  void _handleTicket() async {
    try {
      // Fetch attendance with verification code
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('event_participants')
          .select()
          .eq('event_id', widget.event.id)
          .eq('user_id', userId)
          .single();

      final attendance = EventAttendanceModel.fromJson(response);

      // Get current user profile
      final profileService = ProfileService();
      final currentProfile = await profileService.getProfile(userId);

      // Show QR modal
      if (mounted) {
        QRTicketModal.show(
          context,
          attendance: attendance,
          event: widget.event,
          userName: currentProfile?.fullName ?? 'Kullanıcı',
          userAvatar: currentProfile?.avatarUrl,
        );
      }
    } catch (e) {
      if (mounted) {
        getIt<AppFeedbackService>().showError('QR kod yüklenemedi');
      }
    }
  }

  void _handleContact() {
    debugPrint('💬 İletişim: ${widget.event.id}');
  }

  Future<void> _handleCancelAttendance() async {
    final confirmed = await EventCancelModal.show(context: context);

    if (confirmed != true) return;

    // Loading state
    setState(() => _isProcessingAttendance = true);

    try {
      debugPrint('🚫 Katılımı iptal ediliyor...');

      await _attendanceService.leaveEvent(
        eventId: widget.event.id,
        reason: 'Kullanıcı katılımını iptal etti',
      );

      if (!mounted) return;

      // Durumu güncelle
      setState(() {
        _attendanceStatus = EventAttendanceStatus.notAttending;
        _isProcessingAttendance = false;
      });

      getIt<AppFeedbackService>().showWarning('Katılımınız iptal edildi');

      debugPrint('✅ Katılım başarıyla iptal edildi');
    } catch (e) {
      debugPrint('⚠️ Katılım iptal hatası: $e');

      if (!mounted) return;

      setState(() => _isProcessingAttendance = false);

      getIt<AppFeedbackService>().showError('Katılım iptal edilemedi: $e');
    }
  }
}
