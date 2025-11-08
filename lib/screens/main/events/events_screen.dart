import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/screens/main/events/create_event_screen.dart';
import 'package:lobi_application/screens/main/events/create_event_screen_ex.dart';
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

  @override
  void initState() {
    super.initState();
    // Filter seçeneklerini yükle
    _filterOptions = EventsFilterConfig.getOptions();
    // Varsayılan olarak "Tüm Etkinlikler" seçili
    _selectedFilter = _filterOptions.firstWhere((option) => option.isDefault);
  }

  // Filter seçildiğinde
  void _onFilterSelected(FilterOption option) {
    setState(() {
      _selectedFilter = option;
    });

    // TODO: Burada servis çağrısı yapılacak
    debugPrint('Filter selected: ${option.id} - ${option.label}');
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
          SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 15.h, 0.w, 100.h),
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
                      Text(
                        'Seçili Filter: ${_selectedFilter.label}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Gösterilen: ${_showUpcoming ? 'Yaklaşan' : 'Geçmiş'} Etkinlikler',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.getTextDescColor(context),
                        ),
                      ),
                    ],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventScreen(),
                            fullscreenDialog: true, // ✨ iOS modal görünümü
                          ),
                        );
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
          // Positioned(
          //   bottom: 120,
          //   left: 20,
          //   right: 20,
          //   child: GradientButton(
          //     icon: const Icon(
          //       LucideIcons.circlePlus400,
          //       color: Colors.white,
          //       size: 20,
          //     ),
          //     label: 'Etkinlik Oluştur',
          //     onPressed: () {},
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     textStyle: AppTextStyles.authbuttonLg,
          //   ),
          // ),
        ],
      ),
    );
  }
}
