import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/gradient_button.dart';
import 'package:lobi_application/widgets/auth/auth_bottom_sheet.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/system/background-auth.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.90),
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    child: Center(
                      child: Image.asset(
                        'assets/images/parafoni-logo-dark.png',
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    'Finansal dengen',
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      color: AppTheme.purple900,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'şimdi başlıyor',
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      color: AppTheme.black800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Fişlerini okut, harcamaların otomatik kategorilensin. '
                    'Hepsini tek ekrandan yönet.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.zinc800,
                      height: 1.3,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/parafoni-login-img.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  GradientButton(
                    label: 'Hemen Başla',
                    onPressed: () => showAuthBottomSheet(context),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    textStyle: AppTextStyles.authbuttonLg,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
