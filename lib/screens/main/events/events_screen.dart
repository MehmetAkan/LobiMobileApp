import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_filter_button.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/switches/lobi_segmented_switch.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});
  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with ScrollablePageMixin {
  DateTime? activeDate;
  bool _showUpcoming = true; // true = Yaklaşan, false = Geçmiş

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
            padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 15.h, 0.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                    NavbarFilterButton(
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
}
