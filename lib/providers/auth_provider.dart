import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/user_model.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';

/// Auth Repository Provider
/// Neden: Repository'yi Riverpod ile provide ediyoruz
/// Böylece tüm widget'lardan erişebiliriz
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

/// Auth State Stream Provider
/// Neden: Supabase'den gelen auth state değişikliklerini reaktif olarak dinler
/// User giriş/çıkış yaptığında otomatik güncellenir
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Current User Provider
/// Neden: Mevcut kullanıcıyı senkron olarak almak için
/// Daha hızlı erişim, stream beklemeden
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value;
});

/// Auth Status Provider
/// Neden: Kullanıcının durumunu (authenticated, needsProfile, etc.) kontrol eder
/// AppEntry'de hangi ekrana yönlendireceğimize karar verir
final authStatusProvider = FutureProvider<AuthStatus>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.checkAuthStatus();
});

/// Auth Controller (State Notifier)
/// Neden: Auth işlemlerini (login, logout, verify) yönetir
/// Loading state'i tutar, hata yönetimi yapar
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  /// Email ile OTP gönder
  Future<String?> requestOtp(String email) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.requestOtp(email);

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
        AppLogger.info('✅ OTP gönderildi');
        return null; // Success - hata yok
      } else {
        state = AsyncValue.error(
          result.errorMessage!,
          StackTrace.current,
        );
        return result.errorMessage;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('OTP gönderme hatası', e, stackTrace);
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// OTP kodunu doğrula
  Future<AuthResult?> verifyOtp({
    required String email,
    required String code,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.verifyOtp(
        email: email,
        code: code,
      );

      if (result.isSuccess) {
        state = const AsyncValue.data(null);
        AppLogger.info('✅ OTP doğrulandı');
        return result; // UI'da profile/home'a yönlendirmek için
      } else {
        state = AsyncValue.error(
          result.errorMessage!,
          StackTrace.current,
        );
        return result;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('OTP doğrulama hatası', e, stackTrace);
      return AuthResult.failure('Doğrulama başarısız. Tekrar deneyin.');
    }
  }

  /// Google ile giriş
  // Future<String?> signInWithGoogle() async {
  //   state = const AsyncValue.loading();

  //   try {
  //     final result = await _repository.signInWithGoogle();

  //     if (result.isSuccess) {
  //       state = const AsyncValue.data(null);
  //       AppLogger.info('✅ Google girişi başarılı');
  //       return null;
  //     } else {
  //       state = AsyncValue.error(
  //         result.errorMessage!,
  //         StackTrace.current,
  //       );
  //       return result.errorMessage;
  //     }
  //   } catch (e, stackTrace) {
  //     state = AsyncValue.error(e, stackTrace);
  //     AppLogger.error('Google giriş hatası', e, stackTrace);
  //     return 'Google girişi başarısız. Tekrar deneyin.';
  //   }
  // }
Future<String?> signInWithGoogle() async {
  state = const AsyncValue.loading();

  try {
    final result = await _repository.signInWithGoogle();

    state = const AsyncValue.data(null);
    AppLogger.info('✅ Google OAuth flow başlatıldı');
    return null; // Hata gösterme, auth state dinleyecek
    
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
    AppLogger.error('Google giriş hatası', e, stackTrace);
    return 'Google girişi başarısız. Tekrar deneyin.';
  }
}
  /// Çıkış yap
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
      AppLogger.info('✅ Çıkış yapıldı');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Çıkış hatası', e, stackTrace);
      // Çıkış yaparken hata olsa bile state'i data yap
      state = const AsyncValue.data(null);
    }
  }
}

/// Auth Controller Provider
/// Neden: AuthController'ı provide eder, UI'dan erişim için
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});