import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/screens/main/category/category_detail_screen.dart';
import 'package:lobi_application/screens/main/explore/widgets/all_events_list.dart.dart';
import 'package:lobi_application/screens/main/explore/widgets/popular_events_list.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_search_button.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/categories/categories_grid.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/screens/main/explore/popular_events_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with ScrollablePageMixin {
  DateTime? activeDate;
  final List<CategoryModel> _categories = CategoryModel.getMockCategories();

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryDetailScreen(category: category),
                      ),
                    );
                  },
                ),
                SizedBox(height: 25.h),

                _buildPopularEventsSection(),
                SizedBox(height: 25.h),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: EventsSection(
                    title: 'Tüm etkinlikler',
                    onSeeAll: () {
                      debugPrint('Tümünü gör: Tüm Etkinlikler');
                    },
                    child: AllEventsList(
                      scrollController: scrollController,
                      navbarHeight: navbarHeight,
                      onActiveDateChanged: (date) {
                        setState(() {
                          activeDate = date;
                        });
                      },
                      onEventTap: (event) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        );
                      },
                    ),
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
                              ? const SizedBox.shrink()
                              : _buildDateContent(context, activeDate!),
                        ),
                      ],
                    ),
                  ],
                );
              },
              actions: (scrolled) => [
                const NavbarNotificationButton(),
                // NavbarSearchButton(
                //   onTap: () {
                //     debugPrint('Arama');
                //   },
                // ),
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

  Widget _buildPopularEventsSection() {
    final state = ref.watch(discoverPopularEventsProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 0),
      child: EventsSection(
        title: 'Popüler Etkinlikler',
        onSeeAll: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PopularEventsScreen()),
          );
        },
        child: state.when(
          loading: () => SizedBox(
            height: 240.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Text(
            'Popüler etkinlikler yüklenirken bir sorun oluştu.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextDescColor(context),
            ),
          ),
          data: (events) {
            if (events.isEmpty) {
              return Text(
                'Şu anda öne çıkan popüler etkinlik bulunmuyor.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.getTextDescColor(context),
                ),
              );
            }

            return PopularEventsList(
              events: events,
              onEventTap: (event) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventDetailScreen(event: event),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
