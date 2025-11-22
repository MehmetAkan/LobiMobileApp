import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/utils/logger.dart';

/// Username validation results
enum UsernameValidation { valid, tooShort, tooLong, invalidCharacters, empty }

extension UsernameValidationExtension on UsernameValidation {
  String get message {
    switch (this) {
      case UsernameValidation.valid:
        return '';
      case UsernameValidation.empty:
        return 'Kullanıcı adı boş olamaz';
      case UsernameValidation.tooShort:
        return 'En az 3 karakter gerekli';
      case UsernameValidation.tooLong:
        return 'En fazla 20 karakter olabilir';
      case UsernameValidation.invalidCharacters:
        return 'Sadece küçük harf, rakam, _ ve - kullanabilirsiniz';
    }
  }
}

/// Username service for validation and availability checking
class UsernameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if username is available in database
  Future<bool> checkAvailability(String username) async {
    try {
      final result = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return result == null; // null = available
    } catch (e, stackTrace) {
      AppLogger.error('Username availability check error', e, stackTrace);
      return false; // Hata durumunda güvenli tarafta olalım
    }
  }

  /// Validate username format (client-side)
  static UsernameValidation validateFormat(String username) {
    // Empty check
    if (username.isEmpty) {
      return UsernameValidation.empty;
    }

    // Length check
    if (username.length < 3) {
      return UsernameValidation.tooShort;
    }

    if (username.length > 20) {
      return UsernameValidation.tooLong;
    }

    // Format check (lowercase, alphanumeric, _, -)
    final regex = RegExp(r'^[a-z0-9_-]+$');
    if (!regex.hasMatch(username)) {
      return UsernameValidation.invalidCharacters;
    }

    return UsernameValidation.valid;
  }

  /// Save username to current user's profile
  Future<void> saveUsername(String username) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('profiles')
          .update({'username': username})
          .eq('user_id', userId);

      AppLogger.success('Username saved: $username');
    } catch (e, stackTrace) {
      AppLogger.error('Save username error', e, stackTrace);
      rethrow;
    }
  }
}
