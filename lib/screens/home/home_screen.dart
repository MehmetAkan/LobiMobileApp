import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Geri butonu
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 30),
                        child: AuthBackButton(),
                      ),
                      Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: AppTheme.zinc200,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.userStar400,
                            size: 28,
                            color: AppTheme.zinc800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'ANA SAYFAYA HOŞGELSİN',
                        textAlign: TextAlign.start,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 35,
                          color: AppTheme.black800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
