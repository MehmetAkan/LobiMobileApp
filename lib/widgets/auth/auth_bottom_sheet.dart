import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/screens/auth/mail_screen.dart';

Future<void> showAuthBottomSheet(BuildContext context) {
  final theme = Theme.of(context);
  final text = theme.textTheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    // Builder'ı Consumer ile wrap et
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, child) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/system/parafoni-icon-logo-dark.svg',
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
                          color: AppTheme.zinc200,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppTheme.zinc800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Parafoniye Hoş Geldin',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Başlamak için bir yöntem seç. E-posta ile hızlıca giriş yapabilir '
                  'veya Google hesabını kullanabilirsin.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.35,
                    color: AppTheme.zinc600,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: AppTheme.black800,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MailScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 22,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 25,
                              color: AppTheme.white,
                            ),
                            Spacer(),
                            Text(
                              'E-posta ile bağlan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                                height: 1.3,
                              ),
                            ),
                            Spacer(),
                            SizedBox(width: 20, height: 20),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: AppTheme.zinc100,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
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
                      // onTap: () async {

                      //   final controller = ref.read(authControllerProvider.notifier);
                      //   final error = await controller.signInWithGoogle();

                      //   if (error != null && context.mounted) {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text(error)),
                      //     );
                      //   } else {
                      //     Navigator.of(ctx).pop();
                      //   }
                      // },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 22,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/system/google-icon.svg',
                              height: 25,
                              fit: BoxFit.contain,
                            ),
                            const Spacer(),
                            const Text(
                              'Google ile bağlan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black800,
                                height: 1.3,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 20, height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Devam ederek kullanım şartlarını kabul ediyorsun',
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
