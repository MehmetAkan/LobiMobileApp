import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_compact.dart';
import 'package:lobi_application/screens/main/profile/settings/settings_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int>? _userStats;
  bool _isLoadingStats = true;
  List<EventModel> _attendedEvents = [];
  List<EventModel> _organizedEvents = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserStats();
    _loadUserEvents();
  }

  Future<void> _loadUserStats() async {
    try {
      final profileService = ProfileService();
      final userId = ref.read(currentUserProfileProvider).value?.userId;

      if (userId != null) {
        final stats = await profileService.getUserStats(userId);
        if (mounted) {
          setState(() {
            _userStats = stats;
          });
        }
      }
    } catch (e) {
      debugPrint('Stats yüklenemedi: $e');
    }
  }

  Future<void> _loadUserEvents() async {
    try {
      final userId = ref.read(currentUserProfileProvider).value?.userId;
      if (userId == null) return;

      final eventRepository = getIt<EventRepository>();

      final attended = await eventRepository.getUserAttendedEvents(userId);
      final organized = await eventRepository.getUserOrganizedEvents(userId);

      if (mounted) {
        setState(() {
          _attendedEvents = attended;
          _organizedEvents = organized;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      debugPrint('Events yüklenemedi: $e');
      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Profil yüklenemedi: $error'))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('Profil bulunamadı')));
        }

        return Scaffold(
          body: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverPhoto(),
                    _buildProfileInfo(profile),
                    Transform.translate(
                      offset: Offset(0, -10.h),
                      child: _buildTabs(),
                    ),
                    Transform.translate(
                      offset: Offset(0, -10.h),
                      child: _buildTabContent(),
                    ),
                  ],
                ),
              ),

              // Settings button (positioned)
              _buildSettingsButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverPhoto() {
    return SizedBox(
      height: 110.h,
      width: double.infinity,
      child: AppImage(
        path: 'assets/images/system/profile-cover.png',
        fit: BoxFit.cover,
        placeholder: Container(color: AppTheme.zinc200),
      ),
    );
  }

  Widget _buildSettingsButton() {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Positioned(
      top: statusBarHeight + 0.h,
      right: 20.w,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.getAppBarButtonBorder(context),
              width: 1,
            ),
            color: AppTheme.getAppBarButtonBg(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.settings400,
            size: 22.sp,
            color: AppTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(profile) {
    final fullName = '${profile.firstName} ${profile.lastName}';
    final username = profile.username ?? '';
    final bio = profile.bio ?? '';
    final avatarUrl = profile.avatarUrl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: Offset(0, -25.h),
            child: Row(
              children: [
                ProfileAvatar(
                  imageUrl: avatarUrl,
                  name: fullName,
                  size: 100,
                  border: Border.all(color: Colors.white, width: 4.w),
                ),
                SizedBox(width: 10.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 17.sp,
                        letterSpacing: -0.30,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                    SizedBox(height: 0.h),
                    if (username.isNotEmpty)
                      Text(
                        '@$username',
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: -0.10,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.zinc800,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                        children: [
                          TextSpan(
                            text: '${_userStats?['attended'] ?? 0} ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: 'Katıldı'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '|',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppTheme.zinc400,
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                        children: [
                          TextSpan(
                            text: '${_userStats?['organized'] ?? 0} ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: 'Oluşturdu'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bio.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.getTextHeadColor(context),
                      height: 1,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                _buildSocialMediaRow(profile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          dividerColor: AppTheme.getProfileDivider(context),
          controller: _tabController,
          labelColor: AppTheme.getTextHeadColor(context),
          unselectedLabelColor: AppTheme.zinc500,
          labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: AppTheme.getTextHeadColor(context),
          indicatorWeight: 2.h,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
          tabs: const [
            Tab(text: 'Katıldığı Etkinlikler'),
            Tab(text: 'Oluşturduğu Etkinlikler'),
          ],
        ),
        Container(height: 1.h, color: AppTheme.getProfileDivider(context)),
      ],
    );
  }

  Widget _buildTabContent() {
    final userId = ref.watch(currentUserProfileProvider).value?.userId;
    final screenHeight = MediaQuery.of(context).size.height;
    final tabHeight = screenHeight * 0.5; // Use 50% of screen height for tabs

    return SizedBox(
      height: tabHeight,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Attended events
          _buildEventList(_attendedEvents, 'Henüz hiç etkinliğe katılmadınız'),

          // Organized events
          _buildEventList(
            _organizedEvents,
            'Henüz hiç etkinlik oluşturmadınız',
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events, String emptyMessage) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Text(
            emptyMessage,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.red50),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final userId = ref.watch(currentUserProfileProvider).value?.userId;

    return ListView.separated(
      padding: EdgeInsets.only(
        left: 15.w,
        top: 20.h,
        right: 15.w,
        bottom: 65.h,
      ),
      itemCount: events.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final event = events[index];
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
            // TODO: Navigate to event detail
            debugPrint('Event tapped: ${event.id}');
          },
        );
      },
    );
  }

  /// Build social media icons row
  Widget _buildSocialMediaRow(profile) {
    final List<Map<String, dynamic>> socialMedia = [
      if (profile.instagram != null && profile.instagram!.isNotEmpty)
        {
          'icon': LucideIcons.instagram,
          'url': 'https://instagram.com/${profile.instagram}',
        },
      if (profile.twitter != null && profile.twitter!.isNotEmpty)
        {
          'icon': LucideIcons.twitter,
          'url': 'https://twitter.com/${profile.twitter}',
        },
      if (profile.youtube != null && profile.youtube!.isNotEmpty)
        {
          'icon': LucideIcons.youtube,
          'url': 'https://youtube.com/@${profile.youtube}',
        },
      if (profile.tiktok != null && profile.tiktok!.isNotEmpty)
        {
          'icon': LucideIcons.music, // TikTok icon (Lucide doesn't have tiktok)
          'url': 'https://tiktok.com/@${profile.tiktok}',
        },
      if (profile.linkedin != null && profile.linkedin!.isNotEmpty)
        {
          'icon': LucideIcons.linkedin,
          'url': 'https://linkedin.com/in/${profile.linkedin}',
        },
      if (profile.website != null && profile.website!.isNotEmpty)
        {
          'icon': LucideIcons.globe,
          'url': profile.website!.startsWith('http')
              ? profile.website!
              : 'https://${profile.website}',
        },
    ];

    if (socialMedia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: socialMedia
          .map(
            (social) => Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: GestureDetector(
                onTap: () => _launchUrl(social['url'] as String),
                child: Icon(
                  social['icon'] as IconData,
                  size: 20.sp,
                  color: AppTheme.zinc600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Launch URL helper
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
