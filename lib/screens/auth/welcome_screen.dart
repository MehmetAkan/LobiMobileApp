import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/buttons/gradient_button.dart';
import 'package:lobi_application/widgets/auth/auth_bottom_sheet.dart';
import 'package:lobi_application/widgets/common/overlays/offline_overlay.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(seconds: 100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.85,
              child: SvgPicture.asset(
                'assets/images/system/background-splash.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              // Logo with SafeArea
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/system/logo/lobi-logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Animated sliding image - PANORAMIC EFFECT
              SizedBox(
                height: 350.h,
                width: double.infinity,
                child: ClipRect(
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _slideController,
                        builder: (context, child) {
                          final left = _slideController.value * -1100;

                          return Positioned(
                            left: left,
                            top: 0,
                            bottom: 0,
                            child: child!,
                          );
                        },
                        child: Image.asset(
                          'assets/images/system/auth-photo.png',
                          height: 350,
                          fit: BoxFit.fitHeight, // Natural width korunur
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Şehrinin Sosyal',
                          textAlign: TextAlign.center,
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 45,
                            color: AppTheme.black800,
                            height: 1,
                          ),
                        ),
                        Text(
                          'Haritası',
                          textAlign: TextAlign.center,
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 45,
                            color: AppTheme.black800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Arkadaş buluşmalarından büyük etkinliklere kadar her şeyi Lobi’de planla, paylaş ve beraber sosyalleş.',

                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.zinc800,
                            height: 1.1,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          label: 'Giriş Yap veya Hesap Oluştur',
                          onPressed: () => showAuthBottomSheet(context),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          textStyle: AppTextStyles.authbuttonLg,
                        ),
                        // SizedBox(
                        //   width: double.infinity, // Full width
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.black.withValues(alpha: 0.1),
                        //           blurRadius: 10,
                        //           offset: const Offset(0, 4),
                        //         ),
                        //       ],
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //     child: Material(
                        //       color: AppTheme.black800,
                        //       borderRadius: BorderRadius.circular(30),
                        //       child: InkWell(
                        //         onTap: () => showAuthBottomSheet(context),
                        //         borderRadius: BorderRadius.circular(30),
                        //         child: const Padding(
                        //           padding: EdgeInsets.symmetric(
                        //             vertical: 20,
                        //             horizontal: 22,
                        //           ),
                        //           child: Center(
                        //             child: Text(
                        //               'Giriş Yap veya Hesap Oluştur',
                        //               style: TextStyle(
                        //                 fontSize: 17,
                        //                 fontWeight: FontWeight.w600,
                        //                 color: AppTheme.white,
                        //                 height: 1.3,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const OfflineOverlay(),
        ],
      ),
    );
  }
}
