import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/screens/main/home/widgets/this_week_events_list.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_notification_button.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_horizontal.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_list.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lobi_application/widgets/common/mixins/refreshable_page_mixin.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/indicators/app_refresh_indicator.dart';
import 'package:lobi_application/widgets/common/sections/events_section.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with ScrollablePageMixin, RefreshablePageMixin {
  DateTime? activeDate;

  @override
  List<ProviderOrFamily> getProvidersToRefresh() {
    final providers = <ProviderOrFamily>[homeThisWeekEventsProvider];

    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      providers.add(recommendedEventsProvider(profile.userId));
    }

    return providers;
  }

  Future<void> triggerScrollToTopAndRefresh() async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    HapticFeedback.lightImpact();
    await handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AppRefreshIndicator(
            onRefresh: handleRefresh,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0.w, navbarHeight + 20.h, 0.w, 60.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 0),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final profile = ref.watch(currentUserProfileProvider);

                        return profile.when(
                          data: (userProfile) {
                            if (userProfile == null) {
                              return const SizedBox.shrink();
                            }

                            final recommendedEvents = ref.watch(
                              recommendedEventsProvider(userProfile.userId),
                            );

                            return recommendedEvents.when(
                              data: (events) {
                                if (events.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return EventsSection(
                                  title: 'Beğenebileceğin ve fazlası',
                                  onSeeAll: () {
                                    debugPrint(
                                      'Tümünü gör: Beğenebileceğin ve fazlası',
                                    );
                                  },
                                  child: EventCardList<EventModel>(
                                    items: events,
                                    itemBuilder: (event, index) {
                                      return EventCardHorizontal(
                                        imageUrl: event.imageUrl,
                                        title: event.title,
                                        date: event.date
                                            .toTodayTomorrowWithTime(),
                                        location: event.location,
                                        attendeeCount: event.attendeeCount,
                                        isLiked: false,
                                        showLikeButton: false,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventDetailScreen(
                                                    event: event,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                              loading: () => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, stack) => const SizedBox.shrink(),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: EventsSection(
                      title: 'Bu haftaki etkinlikler',
                      onSeeAll: () {
                        debugPrint('Tümünü gör: Bu haftakiler');
                      },
                      child: _buildThisWeekEvents(navbarHeight),
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
                        'assets/images/system/logo/lobi-icon.svg',
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
                            MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark
                                ? 'assets/images/system/logo/lobitext-white.svg'
                                : 'assets/images/system/logo/lobitext.svg',
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
              actions: (scrolled) => [const NavbarNotificationButton()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekEvents(double navbarHeight) {
    final state = ref.watch(homeThisWeekEventsProvider);

    return state.when(
      loading: () => SizedBox(
        height: 150.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        debugPrint('Bu haftakiler yüklenirken hata: $error');

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Text(
            'Etkinlikler yüklenirken bir sorun oluştu.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.getTextDescColor(context),
            ),
          ),
        );
      },
      data: (groups) {
        final List<EventModel> allEvents = [];
        for (final group in groups) {
          allEvents.addAll(group.events);
        }

        if (allEvents.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Text(
              'Bu hafta için etkinlik bulunmuyor.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.getTextDescColor(context),
              ),
            ),
          );
        }

        return ThisWeekEventsList(
          events: allEvents,
          onEventTap: (event) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateContent(BuildContext context, DateTime date) {
    return Row(
      children: [
        Text(
          '${date.day} ${date.monthName}',
          style: AppTextStyles.titleXXSM.copyWith(
            color: AppTheme.getTextHeadColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          '/ ${date.dayName}',
          style: AppTextStyles.titleXXSM.copyWith(
            color: AppTheme.getNavbarDateDescText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
