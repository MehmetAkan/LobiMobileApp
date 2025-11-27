import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lobi_application/widgets/common/buttons/navbar_new_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Placeholder data
  final String coverPhotoUrl = 'assets/images/system/profile-cover.png';
  final String profilePhotoUrl = 'https://i.pravatar.cc/150?u=profile';
  final String fullName = 'Mehmet Akan';
  final String username = '@mehmetakan';
  final String bio = 'Flutter Developer • Event Organizer';
  final int attendedCount = 20;
  final int organizedCount = 95;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverPhoto(),
                _buildProfileInfo(),
                _buildTabs(),
                _buildTabContent(),
              ],
            ),
          ),

          // Settings button (positioned)
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildCoverPhoto() {
    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: AppImage(
        path: coverPhotoUrl,
        fit: BoxFit.cover,
        placeholder: Container(color: AppTheme.zinc200),
      ),
    );
  }

  Widget _buildSettingsButton() {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Positioned(
      top: statusBarHeight + 10.h,
      right: 20.w,
      child: GestureDetector(
        onTap: () {
          debugPrint('Settings tapped');
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

  Widget _buildProfileInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: Offset(0, -40.h),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: AppImage(
                  path: profilePhotoUrl,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    width: 80.w,
                    height: 80.w,
                    color: AppTheme.zinc300,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextHeadColor(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 16.sp,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.zinc700,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  bio,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.getTextHeadColor(context),
                    height: 1,
                  ),
                ),
                SizedBox(height: 20.h),
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
                            text: '$attendedCount ',
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
                            text: '$organizedCount ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: 'Oluşturdu'),
                        ],
                      ),
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

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          dividerColor: AppTheme.zinc200,
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
          labelPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
          tabs: const [
            Tab(text: 'Katıldığı Etkinlikler'),
            Tab(text: 'Oluşturduğu Etkinlikler'),
          ],
        ),
        Container(height: 1.h, color: AppTheme.zinc200),
      ],
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400.h, // Placeholder height
      child: TabBarView(
        controller: _tabController,
        children: [
          // Attended events
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Text(
                'Katıldığı etkinlikler burada listelenecek',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.zinc600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Organized events
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Text(
                'Oluşturduğu etkinlikler burada listelenecek',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.zinc600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
