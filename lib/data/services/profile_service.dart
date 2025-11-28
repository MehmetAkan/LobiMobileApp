import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/error_handler.dart';

/// Profile Service: Sadece profiles tablosu ile işlemler
class ProfileService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Kullanıcının profilini getir
  /// @throws DatabaseException
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      AppLogger.debug('Profil getiriliyor: $userId');

      final result = await _supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (result == null) {
        AppLogger.debug('Profil bulunamadı: $userId');
        return null;
      }

      final profile = ProfileModel.fromJson(result);
      AppLogger.debug('Profil getirildi: ${profile.fullName}');

      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Profil getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Profil oluştur veya güncelle
  /// @throws DatabaseException
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    try {
      AppLogger.debug('Profil kaydediliyor: ${profile.fullName}');

      await _supabase
          .from(AppConstants.profilesTable)
          .upsert(profile.toJson(), onConflict: 'user_id');

      AppLogger.info('✅ Profil kaydedildi: ${profile.fullName}');

      return profile;
    } catch (e, stackTrace) {
      AppLogger.error('Profil kaydetme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Profil güncelle (partial update)
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.debug('Profil güncelleniyor: $userId');

      await _supabase
          .from(AppConstants.profilesTable)
          .update(updates)
          .eq('user_id', userId);

      AppLogger.info('Profil güncellendi: $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Profil güncelleme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Kullanıcı istatistiklerini getir (katıldığı ve oluşturduğu etkinlik sayıları)
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      AppLogger.debug('Kullanıcı istatistikleri getiriliyor: $userId');

      // Katıldığı etkinlik sayısı
      final attendedResult = await _supabase.rpc(
        'get_user_attended_count',
        params: {'user_id_in': userId},
      );

      // Oluşturduğu etkinlik sayısı
      final organizedResult = await _supabase.rpc(
        'get_user_organized_count',
        params: {'user_id_in': userId},
      );

      final stats = {
        'attended': attendedResult as int? ?? 0,
        'organized': organizedResult as int? ?? 0,
      };

      AppLogger.debug('İstatistikler: $stats');
      return stats;
    } catch (e, stackTrace) {
      AppLogger.error('İstatistikler getirme hatası', e, stackTrace);
      return {'attended': 0, 'organized': 0};
    }
  }

  /// Profil sil (GDPR uyumluluğu için)
  Future<void> deleteProfile(String userId) async {
    try {
      AppLogger.warning('Profil siliniyor: $userId');

      await _supabase
          .from(AppConstants.profilesTable)
          .delete()
          .eq('user_id', userId);

      AppLogger.warning('⚠️ Profil silindi: $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Profil silme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }
}
