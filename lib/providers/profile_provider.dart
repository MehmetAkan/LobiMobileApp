import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:lobi_application/data/repositories/profile_repository.dart';
import 'package:lobi_application/providers/auth_provider.dart';

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return getIt<ProfileRepository>();
});

/// Current User Profile Provider
/// Neden: Mevcut kullanıcının profilini otomatik olarak getirir
/// User değiştiğinde otomatik refresh olur
final currentUserProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  // Auth state'i dinle - user değişirse profil yeniden yüklensin
  final authState = ref.watch(authStateProvider);

  // User yoksa null dön
  if (authState.value == null) {
    return null;
  }

  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getCurrentUserProfile();
});

/// Specific User Profile Provider (userId ile)
/// Neden: Belirli bir kullanıcının profilini getirmek için
/// Örnek kullanım: Başka kullanıcıların profillerini görmek
final userProfileProvider = FutureProvider.family<ProfileModel?, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(profileRepositoryProvider);
  // Bu provider için getProfile metodunu ProfileService'e eklemek gerekir
  // Şimdilik currentUserProfile kullanıyoruz
  return await repository.getCurrentUserProfile();
});

/// Profile Controller (State Notifier)
/// Neden: Profil kaydetme, güncelleme işlemlerini yönetir
class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncValue.data(null));

  Future<ProfileResult?> saveProfile({
    required String firstName,
    required String lastName,
    DateTime? birthDate, // Artık opsiyonel
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.saveProfile(
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
      );

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
        AppLogger.info('✅ Profil kaydedildi: ${result.profile?.fullName}');
        return result;
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
        return result;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Profil kaydetme hatası', e, stackTrace);
      return ProfileResult.failure('Profil kaydedilemedi. Tekrar deneyin.');
    }
  }

  /// Profil güncelle
  Future<String?> updateProfile(Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.updateProfile(updates);

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
        AppLogger.info('✅ Profil güncellendi');
        return null;
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
        return result.errorMessage;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Profil güncelleme hatası', e, stackTrace);
      return 'Profil güncellenemedi. Tekrar deneyin.';
    }
  }
}

/// Profile Controller Provider
final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return ProfileController(repository);
    });
