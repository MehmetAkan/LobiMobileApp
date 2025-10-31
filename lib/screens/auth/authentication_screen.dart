import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/screens/home/home_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/auth/auth_verification_input.dart';

// StatefulWidget → ConsumerStatefulWidget
class AuthenticationScreen extends ConsumerStatefulWidget {
  final String email;

  const AuthenticationScreen({super.key, required this.email});

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

// State → ConsumerState
class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  String _code = '';
  bool isLoading = false;
  String? errorText;

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
                            'Doğrulama Kodu',
                            textAlign: TextAlign.start,
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 35,
                              color: AppTheme.black800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'E-postana doğrulama kodu gönderdik',
                            textAlign: TextAlign.start,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.zinc800,
                              height: 1.3,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.email,
                            textAlign: TextAlign.start,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black800,
                              height: 1.3,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          AuthVerificationInput(
                            onCompleted: (code) {
                              setState(() {
                                _code = code;
                                errorText = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (errorText != null)
                            Text(
                              errorText!,
                              style: text.bodySmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
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
                            final controller = ref.read(authControllerProvider.notifier);
                            final result = await controller.verifyOtp(
                              email: widget.email,
                              code: _code,
                            );

                            if (!mounted) return;

                            if (result?.isSuccess == true) {
                              // Başarılı -> Duruma göre yönlendir
                              if (result!.status == AuthStatus.needsProfile) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateProfileScreen(),
                                  ),
                                );
                              } else {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              // Hata var
                              setState(() {
                                errorText = result?.errorMessage ??
                                    'Doğrulama başarısız. Tekrar deneyin.';
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
        ],
      ),
    );
  }
}