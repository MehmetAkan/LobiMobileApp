import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class ProfileService {
  final SupabaseClient _supabase = SupabaseManager().client;

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum yok');
    }

    final result = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    return result;
  }

  Future<void> createProfile({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Oturum yok');
    }

    await _supabase.from('profiles').insert({
      'user_id': user.id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate.toIso8601String(),
    });
  }
}
