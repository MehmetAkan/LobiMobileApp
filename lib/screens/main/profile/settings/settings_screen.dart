import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/widgets/common/menu/menu_group.dart';
import 'package:lobi_application/screens/main/profile/edit_profile_screen.dart';
import 'package:lobi_application/screens/main/profile/widgets/settings/privacy_policy_modal.dart';
import 'package:lobi_application/screens/main/profile/widgets/settings/terms_of_service_modal.dart';
import 'package:lobi_application/screens/main/profile/widgets/settings/support_modal.dart';
import 'package:lobi_application/screens/main/profile/widgets/settings/logout_modal.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/screens/main/notifications/notifications_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final username = profile.username ?? '';

        return StandardPage(
          title: 'Ayarlar',
          children: [
            // Profile section with edit profile
            _buildProfileGroup(
              context,
              avatarUrl: profile.avatarUrl,
              fullName: fullName,
              username: username,
            ),
            SizedBox(height: 20.h),
            MenuGroup(
              items: [
                MenuItem(
                  icon: LucideIcons.scrollText400,
                  title: 'Gizlilik Sözleşmesi',
                  onTap: () => PrivacyPolicyModal.show(context),
                ),
                MenuItem(
                  icon: LucideIcons.fileUser400,
                  title: 'Kullanıcı Sözleşmesi',
                  onTap: () => TermsOfServiceModal.show(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            MenuGroup(
              items: [
                MenuItem(
                  icon: LucideIcons.bell,
                  title: 'Bildirimler',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                MenuItem(
                  icon: LucideIcons.headset,
                  title: 'Destek',
                  onTap: () => SupportModal.show(context, ref),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.getSettingsCardBg(context),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.getSettingsCardBorder(context),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.smartphone400,
                            size: 22.sp,
                            color: AppTheme.getSettingsCardIcon(context),
                          ),
                          SizedBox(width: 15.w),
                          Text(
                            'Versiyon',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.20,
                              color: AppTheme.getTextHeadColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.20,
                        color: AppTheme.zinc600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            MenuGroup(
              items: [
                MenuItem(
                  icon: LucideIcons.logOut,
                  title: 'Çıkış Yap',
                  isDestructive: true,
                  onTap: () => LogoutModal.show(
                    context,
                    onConfirm: () => _handleLogout(context, ref),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Sign out from Supabase
      await SupabaseManager.instance.client.auth.signOut();

      // Invalidate profile provider
      ref.invalidate(currentUserProfileProvider);

      if (context.mounted) {
        // Navigate to app entry (which handles routing) and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AppEntry()),
          (route) => false, // Remove all routes
        );

        // Show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          getIt<AppFeedbackService>().showSuccess('Çıkış yapıldı');
        });
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (context.mounted) {
        getIt<AppFeedbackService>().showError('Çıkış yapılırken hata oluştu');
      }
    }
  }

  Widget _buildProfileGroup(
    BuildContext context, {
    required String? avatarUrl,
    required String fullName,
    required String username,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.getSettingsCardBorder(context)),
      ),
      child: Column(
        children: [
          // Profile section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            child: Row(
              children: [
                // Profile avatar (32x32 to match icon size)
                ProfileAvatar(imageUrl: avatarUrl, name: fullName, size: 45),
                SizedBox(width: 15.w),

                // Name and username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 17.sp,
                          letterSpacing: -0.20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (username.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Text(
                          '@$username',
                          style: TextStyle(
                            fontSize: 15.sp,
                            letterSpacing: -0.20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getListUsernameColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: AppTheme.getSettingsCardDivider(context)),

          // Edit profile using same menu item style
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profili Düzenle',
                        style: TextStyle(
                          fontSize: 15.sp,
                          letterSpacing: -0.20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20.sp,
                      color: AppTheme.getSettingsCardArrowIcon(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
