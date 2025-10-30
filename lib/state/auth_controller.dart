import 'package:flutter/material.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/screens/auth/authentication_screen.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/screens/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final AuthService _authService;
  final ProfileService _profileService;

  AuthController({AuthService? authService, ProfileService? profileService})
    : _authService = authService ?? AuthService(),
      _profileService = profileService ?? ProfileService();

  Future<void> requestOtpAndGoToVerification({
    required BuildContext context,
    required String email,
    required void Function(String? errorMessage) onError,
  }) async {
    // basic validation
    if (email.isEmpty || !email.contains('@')) {
      onError('Lütfen geçerli bir e-posta gir');
      return;
    }

    try {
      await _authService.requestOtp(email: email);

      // başarılıysa doğrulama ekranına git
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AuthenticationScreen(email: email)),
        );
      }
    } catch (e) {
      onError('OTP gönderilemedi. Lütfen tekrar dene.');
    }
  }

  Future<void> verifyCodeAndRoute({
    required BuildContext context,
    required String email,
    required String code,
    required void Function(String? errorMessage) onError,
  }) async {
    if (code.length < 6) {
      onError('Lütfen 6 haneli kodu gir');
      return;
    }

    try {
      // Supabase doğrulama
      await _authService.verifyOtp(email: email, token: code);

      // Profil var mı kontrol et
      final profile = await _profileService.getMyProfile();

      if (!context.mounted) return;

      if (profile == null) {
        // profil yok -> profil oluşturma ekranına (replace)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
        );
      } else {
        // profil var -> ana sayfaya kadar stack'i temizle
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      onError('Kod doğrulanamadı. Lütfen tekrar dene.');
    }
  }

  Future<void> checkSessionAndRedirect({required BuildContext context}) async {
    final user = AuthService().currentUser;
    if (user == null) {
      return;
    }

    // Kullanıcı login. Şimdi profil var mı diye bakalım.
    final profile = await ProfileService().getMyProfile();

    if (!context.mounted) return;

    if (profile == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> signInWithGoogle({
    required BuildContext context,
    required void Function(String? errorMessage) onError,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      const redirectUri = 'lobi://auth-callback';

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUri,
      );
    } catch (e) {
      onError('Google ile giriş başarısız. Tekrar dene.');
    }
  }
}
