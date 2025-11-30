import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/screens/main/events/create_event_screen.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_filter_button.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_new_button.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/switches/lobi_segmented_switch.dart';
import 'package:lobi_application/widgets/common/filters/filter_bottom_sheet.dart';
import 'package:lobi_application/widgets/common/filters/filter_option.dart';
import 'package:lobi_application/widgets/common/filters/configs/events_filter_config.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_compact.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with ScrollablePageMixin {
  DateTime? activeDate;
  bool _showUpcoming = true; // true = Yaklaşan, false = Geçmiş

  // Filter state
  late FilterOption _selectedFilter;
  late List<FilterOption> _filterOptions;

  // Data state
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _pastEvents = [];
  bool _isLoading = false;
  String? _error;

  Route _createEventRoute() {
    return PageRouteBuilder(
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const CreateEventScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Filter seçeneklerini yükle
    _filterOptions = EventsFilterConfig.getOptions();
    // Varsayılan olarak "Tüm Etkinlikler" seçili
    _selectedFilter = _filterOptions.firstWhere((option) => option.isDefault);

    // Load events
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = getIt<AuthRepository>().currentUser?.id;
      if (userId == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final repository = getIt<EventRepository>();

      final upcoming = await repository.getUserUpcomingEvents(userId);
      final past = await repository.getUserPastEvents(userId);

      setState(() {
        _upcomingEvents = upcoming;
        _pastEvents = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<EventModel> _getFilteredEvents() {
    final userId = getIt<AuthRepository>().currentUser?.id;
    final events = _showUpcoming ? _upcomingEvents : _pastEvents;

    switch (_selectedFilter.id) {
      case 'all':
        return events;
      case 'organizer':
        // Events where user is the organizer
        return events.where((e) => e.organizerId == userId).toList();
      case 'attending':
        // Events where user is attending (status = 'attending')
        return events.where((e) => e.attendanceStatus == 'attending').toList();
      case 'pending':
        // Events where user approval is pending (status = 'pending')
        return events.where((e) => e.attendanceStatus == 'pending').toList();
      case 'rejected':
        // Events where user was rejected (status = 'rejected')
        return events.where((e) => e.attendanceStatus == 'rejected').toList();
      default:
        return events;
    }
  }

  // Filter seçildiğinde
  void _onFilterSelected(FilterOption option) {
    setState(() {
      _selectedFilter = option;
    });
  }

  // Filter bottom sheet'i aç
  void _openFilterSheet() {
    FilterBottomSheet.show(
      context: context,
      options: _filterOptions,
      selectedOption: _selectedFilter,
      onOptionSelected: _onFilterSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;
    final isFilterActive = !_selectedFilter.isDefault;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadEvents,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                0.w,
                navbarHeight + 15.h,
                0.w,
                100.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LobiSegmentedSwitch(
                                isFirstSelected: _showUpcoming,
                                firstLabel: 'Yaklaşan',
                                secondLabel: 'Geçmiş',
                                onChanged: (isFirst) {
                                  setState(() {
                                    _showUpcoming = isFirst;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10.w),
                            NavbarFilterButton(
                              isActive: isFilterActive,
                              onTap: _openFilterSheet,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                  // Event List
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            Text(
                              'Hata oluştu',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.red500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _error!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.zinc600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: _loadEvents,
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_getFilteredEvents().isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text(
                          'Henüz etkinlik yok',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppTheme.zinc600,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 20.h),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _getFilteredEvents().length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 25.h),
                        itemBuilder: (context, index) {
                          final event = _getFilteredEvents()[index];
                          final userId =
                              getIt<AuthRepository>().currentUser?.id;

                          return EventCardCompact(
                            imageUrl: event.imageUrl,
                            title: event.title,
                            date: event.date,
                            location: event.location,
                            isOrganizer: event.organizerId == userId,
                            organizerName: event.organizerName,
                            organizerUsername: event.organizerUsername,
                            organizerPhotoUrl: event.organizerPhotoUrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailScreen(event: event),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
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
                          child: Text(
                            "Etkinlikler",
                            style: TextStyle(
                              fontSize: activeDate != null ? 20.sp : 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextHeadColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              actions: (scrolled) => [
                Row(
                  children: [
                    NavbarNewButton(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).push(_createEventRoute());
                      },
                    ),
                    SizedBox(width: 10.w),
                    const NavbarNotificationButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
