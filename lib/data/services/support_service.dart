import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Support Service: Handles support message operations
class SupportService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Check rate limit: max 2 messages in 5 minutes
  Future<bool> canSendMessage({required String userId}) async {
    try {
      AppLogger.debug('🔍 Rate limit kontrolü başlıyor: $userId');

      final fiveMinutesAgo = DateTime.now().subtract(
        const Duration(minutes: 5),
      );
      AppLogger.debug(
        '🕐 5 dakika öncesi: ${fiveMinutesAgo.toIso8601String()}',
      );

      final response = await _supabase
          .from('support_messages')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', fiveMinutesAgo.toIso8601String());

      AppLogger.debug('📊 Response: $response');
      final count = (response as List).length;
      AppLogger.debug('📈 Son 5 dakikada $count mesaj gönderildi');

      final canSend = count < 2;
      AppLogger.debug(canSend ? '✅ Gönderebilir' : '❌ Rate limit aşıldı');

      return canSend; // Max 2 messages
    } catch (e, stackTrace) {
      AppLogger.error('❌ Rate limit kontrolü hatası', e, stackTrace);
      return true; // On error, allow (fail open)
    }
  }

  /// Send a support message
  /// @throws DatabaseException
  Future<void> sendSupportMessage({
    required String userId,
    required String message,
  }) async {
    try {
      AppLogger.debug('Destek mesajı gönderiliyor: $userId');

      await _supabase.from('support_messages').insert({
        'user_id': userId,
        'message': message,
      });

      AppLogger.info('✅ Destek mesajı gönderildi');
    } catch (e, stackTrace) {
      AppLogger.error('Destek mesajı gönderme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }
}
