import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/theme/app_theme.dart';

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
    builder: (ctx) {
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
                    Navigator.of(context).pop(); // modal kapatma
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
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
            Text(
              'Parafoni’ye Hoş Geldin',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
            ),
            const SizedBox(height: 3),
            Text(
              'Başlamak için bir yöntem seç. E-posta ile hızlıca giriş yapabilir '
              'veya Google hesabını kullanabilirsin.',
              style: const TextStyle(
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
                    print('Butona basıldı');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 22,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          size: 25,
                          color: AppTheme.white,
                        ),
                        const Spacer(),
                        const Text(
                          'E-posta ile bağlan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
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
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.zinc300, 
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: AppTheme.zinc100,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    print('Butona basıldı: GOOGLE');
                  },
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
