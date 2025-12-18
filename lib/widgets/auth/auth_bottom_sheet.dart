import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/screens/auth/mail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAuthBottomSheet(BuildContext context) {
  final theme = Theme.of(context);
  final text = theme.textTheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets;

      return AnimatedPadding(
        padding: EdgeInsets.only(
          left: 5.w,
          right: 5.w,
          bottom: 5.h + viewInsets.bottom,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.r),
              topLeft: Radius.circular(30.r),
              bottomLeft: Radius.circular(45.r),
              bottomRight: Radius.circular(45.r),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: SafeArea(
            top: false,
            child: Consumer(
              builder: (context, ref, child) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/system/logo/lobi-icon.svg',
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          InkWell(
                            onTap: () {
                              final nav = Navigator.maybeOf(context);
                              if (nav != null && nav.canPop()) {
                                nav.pop();
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                color: AppTheme.zinc300,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppTheme.zinc900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Lobi’ye Katıl',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.55,
                          fontSize: 25,
                          color: AppTheme.black800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Etkinlikleri takip et veya kendi etkinliklerini düzenle',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.25,
                          color: AppTheme.zinc700,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.zinc300, width: 1),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black800.withAlpha(10),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: AppTheme.black800,
                          borderRadius: BorderRadius.circular(25),
                          child: InkWell(
                            onTap: () async {
                              final controller = ref.read(
                                authControllerProvider.notifier,
                              );
                              final error = await controller.signInWithApple();

                              Navigator.of(context).pop();

                              if (error != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppTheme.zinc800,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/system/apple-icon.svg',
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Apple ile devam et',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.zinc300, width: 1),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black800.withAlpha(10),
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(25),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () async {
                              final controller = ref.read(
                                authControllerProvider.notifier,
                              );
                              final error = await controller.signInWithGoogle();

                              Navigator.of(ctx).pop();

                              if (error != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppTheme.zinc800,
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/system/google-icon.svg',
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Google ile devam et',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.black800,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.zinc300, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MailScreen(),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mail_outline,
                                    size: 24,
                                    color: AppTheme.black800,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'E-posta ile bağlan',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.black800,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              height: 1.4,
                              color: AppTheme.zinc500,
                            ),
                            children: [
                              const TextSpan(text: 'Devam ederek '),
                              TextSpan(
                                text: 'Kullanım Şartları’nı',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1.4,
                                  color: AppTheme.zinc800,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://lobiapp.co/terms-of-service',
                                      ),
                                      mode: LaunchMode.inAppBrowserView,
                                    );
                                  },
                              ),
                              const TextSpan(text: ' ve '),
                              TextSpan(
                                text: 'Gizlilik Politikası’nı',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  height: 1.4,
                                  color: AppTheme.zinc800,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://lobiapp.co/privacy-policy',
                                      ),
                                      mode: LaunchMode.inAppBrowserView,
                                    );
                                  },
                              ),
                              const TextSpan(text: ' kabul etmiş olursun.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
