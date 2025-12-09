import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/auth/auth_verification_input.dart';
import 'package:lobi_application/widgets/common/overlays/offline_overlay.dart';

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
                            decoration: BoxDecoration(
                              color: AppTheme.getAuthIconBg(context),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.mail_outline,
                                size: 30,
                                color: AppTheme.getAuthIconColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Doğrulama Kodu',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 35.sp,
                              letterSpacing: -0.20,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getAuthHeadText(context),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'E-postana doğrulama kodu gönderdik',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15.sp,
                              letterSpacing: -0.20,
                              height: 1.1,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.getAuthDescText(context),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.email,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15.sp,
                              letterSpacing: -0.20,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getAuthHeadText(context),
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
                              style: TextStyle(
                                fontSize: 15.sp,
                                letterSpacing: -0.20,
                                height: 1,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.red700,
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
                            final controller = ref.read(
                              authControllerProvider.notifier,
                            );
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
                                // Navigate to AppEntry (auth listener will handle routing)
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AppEntry(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              // Hata var
                              setState(() {
                                errorText =
                                    result?.errorMessage ??
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
          const OfflineOverlay(),
        ],
      ),
    );
  }
}
