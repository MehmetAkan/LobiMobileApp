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
   
      throw Exception(e.message);
    } catch (e) {
      throw Exception('OTP isteği sırasında bilinmeyen bir hata oluştu.');
    }
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token, 
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Kod doğrulanırken bilinmeyen bir hata oluştu.');
    }
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Future<void> signOut() async {
    
    try {
      await _supabase.auth.signOut();
    } catch (e) {
     
    }
  }
}