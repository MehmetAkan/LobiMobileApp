import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';

// StatelessWidget → ConsumerWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    // Profil bilgisini provider'dan al
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.value;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 30),
                            child: AuthBackButton(),
                          ),
                          TextButton(
                            onPressed: () async {
                              // BURASI DEĞİŞTİ: Controller yerine Provider
                              final controller = ref.read(authControllerProvider.notifier);
                              await controller.signOut();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AppEntry(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Çıkış Yap',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Profil bilgisi ile kişiselleştirilmiş hoşgeldin mesajı
                      Text(
                        profile != null
                            ? 'HOŞGELDİN, ${profile.firstName.toUpperCase()}!'
                            : 'ANA SAYFAYA HOŞGELDİN',
                        textAlign: TextAlign.start,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 35,
                          color: AppTheme.black800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Profil detayları (opsiyonel)
                      if (profile != null)
                        Text(
                          'Yaş: ${profile.age} • ${profile.fullName}',
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.zinc600,
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