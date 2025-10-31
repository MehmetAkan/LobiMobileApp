import 'package:lobi_application/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:lobi_application/data/models/user_model.dart';


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

      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null,
      );

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

      AppLogger.logAuthEvent('otp_verify_success', 
        params: {'userId': response.user!.id});

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
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Google signin hatası', e, stackTrace);
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
}