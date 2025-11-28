import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _usernameController.text = profile.username ?? '';
      _bioController.text = profile.bio ?? '';
      // TODO: Load social media accounts
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
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

        final fullName = '${profile.firstName} ${profile.lastName}';

        return StandardPage(
          title: 'Profili Düzenle',
          children: [
            // Profile Photo with Camera Icon
            _buildProfilePhoto(
              context,
              avatarUrl: profile.avatarUrl,
              fullName: fullName,
            ),
            SizedBox(height: 30.h),

            // Personal Info Section
            _buildPersonalInfoSection(),
            SizedBox(height: 20.h),

            // Biography Section
            _buildSectionTitle('Biyografi'),
            SizedBox(height: 10.h),
            _buildBioInput(),
            SizedBox(height: 20.h),

            // Social Accounts Section
            _buildSectionTitle('Sosyal Hesaplar'),
            SizedBox(height: 10.h),
            _buildSocialAccountsSection(),
          ],
        );
      },
    );
  }

  Widget _buildProfilePhoto(
    BuildContext context, {
    required String? avatarUrl,
    required String fullName,
  }) {
    return Center(
      child: Stack(
        children: [
          // Profile Avatar
          ProfileAvatar(imageUrl: avatarUrl, name: fullName, size: 100),
          // Camera Icon
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                debugPrint('Change photo tapped');
                // TODO: Photo picker
              },
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppTheme.black800,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 3),
                ),
                child: Icon(
                  LucideIcons.camera,
                  size: 18.sp,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.zinc100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.zinc200),
      ),
      child: Column(
        children: [
          _buildInfoRow('İsim', _firstNameController),
          _buildDivider(),
          _buildInfoRow('Soyad', _lastNameController),
          _buildDivider(),
          _buildInfoRow('Kullanıcı Adı', _usernameController),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                letterSpacing: -0.20,
                fontWeight: FontWeight.w600,
                color: AppTheme.zinc700,
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.black800,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: label,
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.zinc600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppTheme.zinc300);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          letterSpacing: -0.20,
          fontWeight: FontWeight.w600,
          color: AppTheme.zinc600,
        ),
      ),
    );
  }

  Widget _buildBioInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.zinc100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.zinc200),
      ),
      padding: EdgeInsets.all(15.w),
      child: TextField(
        controller: _bioController,
        maxLines: 5,
        maxLength: 200,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.black800,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Kendiniz hakkında birkaç kelime yazın...',
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.zinc600,
          ),
          counterStyle: TextStyle(fontSize: 12.sp, color: AppTheme.zinc500),
        ),
      ),
    );
  }

  Widget _buildSocialAccountsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.zinc100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.zinc200),
      ),
      child: Column(
        children: [
          _buildSocialRow(
            'Instagram',
            'assets/images/system/settings/instagram.png',
            _instagramController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'TikTok',
            'assets/images/system/settings/tiktok.png',
            _tiktokController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'YouTube',
            'assets/images/system/settings/youtube.png',
            _youtubeController,
          ),

          _buildDivider(),
          _buildSocialRow(
            'LinkedIn',
            'assets/images/system/settings/linkedin.png',
            _linkedinController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'Website',
            'assets/images/system/settings/web.png',
            _websiteController,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(
    String label,
    String? svgPath,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        children: [
          // Icon/SVG
          SizedBox(
            width: 24.sp,
            height: 24.sp,
            child: icon != null
                ? Icon(icon, size: 20.sp, color: AppTheme.zinc600)
                : Image.asset(
                    svgPath!,
                    width: 24.sp,
                    height: 24.sp,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      LucideIcons.link,
                      size: 20.sp,
                      color: AppTheme.zinc600,
                    ),
                  ),
          ),
          SizedBox(width: 15.w),
          // Platform Name
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                letterSpacing: -0.20,
                fontWeight: FontWeight.w500,
                color: AppTheme.zinc600,
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.black800,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'kullanıcıadı',
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.zinc600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
