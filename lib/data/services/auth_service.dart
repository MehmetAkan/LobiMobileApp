import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/supabase_client.dart';
class AuthService {
  final SupabaseClient _supabase = SupabaseManager().client;

  Future<void> requestOtp({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, 
       
      );
    } on AuthException catch (e) {
      // Supabase spesifik hata
      throw Exception('OTP gönderilemedi: ${e.message}');
    } catch (e) {
      // Diğer hatalar
      throw Exception('Bilinmeyen hata: $e');
    }
  }

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

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
