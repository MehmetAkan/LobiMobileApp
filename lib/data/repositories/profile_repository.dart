import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';

/// Profile işlemlerinin sonucunu tutan model
class ProfileResult {
  final bool isSuccess;
  final String? errorMessage;
  final ProfileModel? profile;

  const ProfileResult._({
    required this.isSuccess,
    this.errorMessage,
    this.profile,
  });

  factory ProfileResult.success(ProfileModel profile) {
    return ProfileResult._(isSuccess: true, profile: profile);
  }

  factory ProfileResult.failure(String errorMessage) {
    return ProfileResult._(isSuccess: false, errorMessage: errorMessage);
  }
}

/// Profile Repository: Profil ile ilgili business logic
class ProfileRepository {
  final ProfileService _profileService;
  final AuthService _authService;

  ProfileRepository(this._profileService, this._authService);

  /// Mevcut kullanıcının profilini getir
  Future<ProfileModel?> getCurrentUserProfile() async {
    try {
      final user = _authService.currentUser;

      if (user == null) {
        AppLogger.warning('Profil getirilemedi: Kullanıcı giriş yapmamış');
        return null;
      }

      return await _profileService.getProfile(user.id);
    } catch (e) {
      AppLogger.error('Profil getirme hatası', e);
      return null;
    }
  }

  /// Profil oluştur veya güncelle
  /// Business logic: Validation + kullanıcı kontrolü
  Future<ProfileResult> saveProfile({
    required String firstName,
    required String lastName,
    DateTime? birthDate, // Artık opsiyonel - Apple Review
  }) async {
    try {
      // Kullanıcı kontrolü
      final user = _authService.currentUser;
      if (user == null) {
        return ProfileResult.failure(
          'Oturum bulunamadı. Lütfen tekrar giriş yapın.',
        );
      }

      // Validation
      if (firstName.trim().isEmpty) {
        return ProfileResult.failure('Lütfen adınızı girin');
      }

      if (lastName.trim().isEmpty) {
        return ProfileResult.failure('Lütfen soyadınızı girin');
      }

      // Yaş kontrolü kaldırıldı - birthDate artık opsiyonel

      AppLogger.info('💾 Profil kaydediliyor: $firstName $lastName');

      // Profil modeli oluştur
      final profile = ProfileModel(
        userId: user.id,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        birthDate: birthDate,
      );

      // Kaydet
      final savedProfile = await _profileService.upsertProfile(profile);

      AppLogger.info('✅ Profil başarıyla kaydedildi');
      return ProfileResult.success(savedProfile);
    } on AppException catch (e) {
      return ProfileResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Profil kaydetme hatası', e);
      return ProfileResult.failure('Profil kaydedilemedi. Tekrar deneyin.');
    }
  }

  /// Profil güncelle (partial update için)
  Future<ProfileResult> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        return ProfileResult.failure('Oturum bulunamadı');
      }

      await _profileService.updateProfile(user.id, updates);

      final updatedProfile = await _profileService.getProfile(user.id);
      if (updatedProfile == null) {
        return ProfileResult.failure('Profil güncellenemedi');
      }

      return ProfileResult.success(updatedProfile);
    } on AppException catch (e) {
      return ProfileResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Profil güncelleme hatası', e);
      return ProfileResult.failure('Profil güncellenemedi. Tekrar deneyin.');
    }
  }
}
