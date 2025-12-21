import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Registration Success Screen
/// Kullanıcı kay��t sürecini tamamladığında gösterilir.
/// "Devam Et" butonuna basıldığında profil provider'ı invalidate edilir ve AppEntry'ye yönlendirilir.
class RegistrationSuccessScreen extends ConsumerWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppTheme.green500.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          LucideIcons.circleCheck400,
                          size: 60.sp,
                          color: AppTheme.green500,
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Title
                    Text(
                      'Hoş Geldin!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35.sp,
                        letterSpacing: -0.20,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getAuthHeadText(context),
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'Hesabın başarıyla oluşturuldu.\nŞimdi seni etkinliklere götürelim!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: -0.20,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getAuthDescText(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Continue Button
              AuthPrimaryButton(
                label: 'Devam Et',
                onTap: () async {
                  debugPrint('🎯 Success screen - Devam Et tapped');

                  // Invalidate profile provider to force fresh data load
                  ref.invalidate(currentUserProfileProvider);

                  // Navigate to AppEntry which will handle routing based on auth state
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AppEntry()),
                      (route) => false, // Clear all previous routes
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
