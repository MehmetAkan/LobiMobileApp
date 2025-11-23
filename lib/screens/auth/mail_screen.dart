import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/screens/auth/authentication_screen.dart';
import 'package:lobi_application/widgets/auth/auth_text_field.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/common/overlays/offline_overlay.dart';

// StatefulWidget → ConsumerStatefulWidget (tek değişiklik)
class MailScreen extends ConsumerStatefulWidget {
  const MailScreen({super.key});

  @override
  ConsumerState<MailScreen> createState() => _MailScreenState();
}

// State<MailScreen> → ConsumerState<MailScreen> (tek değişiklik)
class _MailScreenState extends ConsumerState<MailScreen> {
  final emailCtrl = TextEditingController();

  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                Icons.mail_outline,
                                size: 30,
                                color: AppTheme.zinc800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'E-posta adresiyle devam edin',
                            textAlign: TextAlign.start,
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 35,
                              color: AppTheme.black800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fişlerini okut, harcamaların otomatik kategorilensin. '
                            'Hepsini tek ekrandan yönet.',
                            textAlign: TextAlign.start,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.zinc800,
                              height: 1.3,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          AuthTextField(
                            label: 'E-posta adresin',
                            controller: emailCtrl,
                            hintText: 'ornek@mail.com',
                            keyboardType: TextInputType.emailAddress,
                            errorText: errorText,
                            suffix: const Icon(
                              Icons.mail_outline,
                              size: 24,
                              weight: 1,
                              color: AppTheme.zinc600,
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                  AuthPrimaryButton(
                    label: isLoading ? 'Gönderiliyor...' : 'Devam Et',
                    onTap: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                              errorText = null;
                            });

                            // BURASI DEĞİŞTİ: Controller yerine Provider
                            final controller = ref.read(
                              authControllerProvider.notifier,
                            );
                            final error = await controller.requestOtp(
                              emailCtrl.text.trim(),
                            );

                            if (!mounted) return;

                            if (error == null) {
                              // Başarılı -> Authentication screen'e git
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AuthenticationScreen(
                                    email: emailCtrl.text.trim(),
                                  ),
                                ),
                              );
                            } else {
                              // Hata var
                              setState(() {
                                errorText = error;
                              });
                            }

                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          const OfflineOverlay(),
        ],
      ),
    );
  }
}
