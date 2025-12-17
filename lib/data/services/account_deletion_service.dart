import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Account Deletion Service
/// Hesap silme taleplerini yönetir
class AccountDeletionService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Hesap silme talebi oluştur
  /// 30 gün sonra otomatik silinir
  Future<Map<String, dynamic>> requestAccountDeletion() async {
    try {
      AppLogger.info('Hesap silme talebi oluşturuluyor...');

      final response = await _supabase.rpc('request_account_deletion');

      AppLogger.info('✅ Hesap silme talebi oluşturuldu');

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      AppLogger.error('Hesap silme talebi hatası', e);
      throw ErrorHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.error('Hesap silme talebi hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Silme talebi durumunu kontrol et
  Future<DeletionRequest?> getDeletionRequest() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('User not authenticated for deletion request check');
        return null;
      }

      final response = await _supabase
          .from('account_deletion_requests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DeletionRequest.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Deletion request check error', e);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Deletion request check error', e, stackTrace);
      return null;
    }
  }

  /// Manuel iptal (kullanıcı kararı)
  Future<void> cancelDeletionRequest() async {
    try {
      AppLogger.info('Silme talebi iptal ediliyor...');

      await _supabase.rpc('cancel_account_deletion_on_login');

      AppLogger.info('✅ Silme talebi iptal edildi');
    } on PostgrestException catch (e) {
      AppLogger.error('Deletion cancellation error', e);
      throw ErrorHandler.handle(e);
    } catch (e, stackTrace) {
      AppLogger.error('Deletion cancellation error', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }
}

/// Deletion Request Model
class DeletionRequest {
  final String id;
  final String userId;
  final DateTime requestedAt;
  final DateTime scheduledDeletionAt;
  final String status;

  DeletionRequest({
    required this.id,
    required this.userId,
    required this.requestedAt,
    required this.scheduledDeletionAt,
    required this.status,
  });

  factory DeletionRequest.fromJson(Map<String, dynamic> json) {
    return DeletionRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      scheduledDeletionAt: DateTime.parse(
        json['scheduled_deletion_at'] as String,
      ),
      status: json['status'] as String,
    );
  }

  /// Kalan gün sayısı
  int get daysRemaining {
    final now = DateTime.now();
    final difference = scheduledDeletionAt.difference(now);
    return difference.inDays;
  }
}
