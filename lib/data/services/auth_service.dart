import 'dart:io';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:lobi_application/data/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Mevcut kullanıcıyı al
  UserModel? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  /// Auth state değişikliklerini dinle
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  Future<void> requestOtp({required String email}) async {
    try {
      AppLogger.logAuthEvent('otp_request_started', params: {'email': email});

      await _supabase.auth.signInWithOtp(email: email, emailRedirectTo: null);

      AppLogger.logAuthEvent('otp_request_success');
    } catch (e, stackTrace) {
      AppLogger.error('OTP request hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  Future<UserModel> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      AppLogger.logAuthEvent('otp_verify_started');

      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user == null) {
        throw AuthenticationException('Kullanıcı oluşturulamadı');
      }

      AppLogger.logAuthEvent(
        'otp_verify_success',
        params: {'userId': response.user!.id},
      );

      // Hesap silme talebini otomatik iptal et
      await checkAndCancelPendingDeletion();

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e, stackTrace) {
      AppLogger.error('OTP verify hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  Future<bool> signInWithGoogle({required String redirectUrl}) async {
    try {
      AppLogger.logAuthEvent('google_signin_started');

      final result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!result) {
        AppLogger.warning('Google signin cancelled');
        return false;
      }

      AppLogger.logAuthEvent('google_signin_success');

      // Hesap silme talebini otomatik iptal et
      await checkAndCancelPendingDeletion();

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Google signin hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Apple ile giriş yap
  Future<bool> signInWithApple() async {
    try {
      // Platform kontrolü
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw AuthenticationException(
          'Apple Sign In sadece iOS ve macOS\'ta desteklenir',
        );
      }

      AppLogger.logAuthEvent('apple_signin_started');

      // Apple credential al
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Name bilgilerini yakala (ilk Sign In'de gelir, sonra gelmez)
      final givenName = credential.givenName;
      final familyName = credential.familyName;

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw AuthenticationException(
          'Apple Sign In başarısız: ID token alınamadı',
        );
      }

      // Supabase ile giriş yap
      final authResponse = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      if (authResponse.user == null) {
        throw AuthenticationException(
          'Apple Sign In başarısız: Kullanıcı oluşturulamadı',
        );
      }

      // Name bilgileri varsa metadata'ya ekle
      if (givenName != null || familyName != null) {
        final fullName = '${givenName ?? ''} ${familyName ?? ''}'.trim();
        if (fullName.isNotEmpty) {
          AppLogger.info(
            '🍎 Apple name bilgisi metadata\'ya ekleniyor: $fullName',
          );

          await _supabase.auth.updateUser(
            UserAttributes(
              data: {
                'full_name': fullName,
                'given_name': givenName,
                'family_name': familyName,
              },
            ),
          );
        }
      }

      AppLogger.logAuthEvent('apple_signin_success');

      // Hesap silme talebini otomatik iptal et
      await checkAndCancelPendingDeletion();

      return true;
    } catch (e, stackTrace) {
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          AppLogger.warning('Apple signin cancelled');
          return false; // Kullanıcı iptal etti
        }
      }
      AppLogger.error('Apple signin hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      AppLogger.logAuthEvent('signout_started');

      await _supabase.auth.signOut();

      AppLogger.logAuthEvent('signout_success');
    } catch (e, stackTrace) {
      AppLogger.error('Signout hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Session'ı yenile
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      AppLogger.info('Session refreshed');
    } catch (e, stackTrace) {
      AppLogger.error('Session refresh hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Pending hesap silme talebini iptal et (login sonrası kontrol)
  Future<void> checkAndCancelPendingDeletion() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return; // Login değilse skip

      await _supabase.rpc('cancel_account_deletion_on_login');
      AppLogger.info('🔄 Pending deletion request cancelled (if any)');
    } catch (e) {
      // Hata olsa bile devam et (silme talebi yoksa hata verir)
      AppLogger.warning('Deletion cancellation check: $e');
    }
  }
}
