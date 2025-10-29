import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/supabase_client.dart';
class AuthService {
  final SupabaseClient _supabase = SupabaseManager().client;

  /// 1. Kullanıcı e-mailini girdiğinde çağıracağız.
  /// Bu fonksiyon Supabase'e "bu maile kod gönder" der.
  Future<void> requestOtp({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, 
        // mobile app olduğumuz için redirect linke şimdilik ihtiyacımız yok.
        // İleride deep link kurarsak bunu doldururuz.
      );
    } on AuthException catch (e) {
      // Supabase spesifik hata
      throw Exception('OTP gönderilemedi: ${e.message}');
    } catch (e) {
      // Diğer hatalar
      throw Exception('Bilinmeyen hata: $e');
    }
  }

  /// 2. Kullanıcı 6 haneli kodu girdiğinde çağıracağız.
  /// Bu fonksiyon kodu doğrular ve session döner (giriş yapar).
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token, // kullanıcının girdiği 6 haneli kod
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      // response.session içinde accessToken vs var.
      // response.user içinde Supabase user var.
      return response;
    } on AuthException catch (e) {
      throw Exception('Kod doğrulanamadı: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen hata: $e');
    }
  }

  /// Aktif kullanıcı bilgisini getir (ör: profile screen vs için)
  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  /// Oturumu kapat
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
