import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/user_model.dart';
import 'package:lobi_application/data/models/profile_model.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';

/// Auth durumlarını temsil eden enum
enum AuthStatus {
  authenticated,      // Kullanıcı giriş yapmış
  unauthenticated,   // Kullanıcı giriş yapmamış
  needsProfile,      // Giriş yapmış ama profil eksik
}

/// Auth işlemlerinin sonucunu tutan model
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final AuthStatus? status;
  final UserModel? user;
  final ProfileModel? profile;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.status,
    this.user,
    this.profile,
  });

  factory AuthResult.success({
    required AuthStatus status,
    UserModel? user,
    ProfileModel? profile,
  }) {
    return AuthResult._(
      isSuccess: true,
      status: status,
      user: user,
      profile: profile,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Auth Repository: Auth ile ilgili tüm business logic burada
/// Service'leri koordine eder, kullanıcı durumunu yönetir
class AuthRepository {
  final AuthService _authService;
  final ProfileService _profileService;

  AuthRepository(this._authService, this._profileService);

  /// Mevcut kullanıcı
  UserModel? get currentUser => _authService.currentUser;

  /// Auth state değişikliklerini dinle
  Stream<UserModel?> get authStateChanges => _authService.authStateChanges;

  /// Email ile OTP gönder
  /// Business logic: Email validasyonu burada yapılır
  Future<AuthResult> requestOtp(String email) async {
    try {
      // Validation
      if (email.isEmpty || !_isValidEmail(email)) {
        return AuthResult.failure('Lütfen geçerli bir e-posta adresi girin');
      }

      AppLogger.info('📧 OTP gönderiliyor: $email');
      await _authService.requestOtp(email: email);

      return AuthResult.success(status: AuthStatus.unauthenticated);
    } on AppException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      return AuthResult.failure('Bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  /// OTP kodunu doğrula ve kullanıcı durumunu belirle
  /// Business logic: Kod doğrulama + profil kontrolü
  Future<AuthResult> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      // Validation
      if (code.length != 6) {
        return AuthResult.failure('Lütfen 6 haneli kodu girin');
      }

      AppLogger.info('🔐 OTP doğrulanıyor...');
      
      // 1. Kodu doğrula
      final user = await _authService.verifyOtp(email: email, token: code);
      
      // 2. Profil var mı kontrol et
      final profile = await _profileService.getProfile(user.id);

      if (profile == null) {
        AppLogger.info('⚠️ Profil bulunamadı, oluşturulması gerekiyor');
        return AuthResult.success(
          status: AuthStatus.needsProfile,
          user: user,
        );
      }

      AppLogger.info('✅ Giriş başarılı: ${profile.fullName}');
      return AuthResult.success(
        status: AuthStatus.authenticated,
        user: user,
        profile: profile,
      );
    } on AppException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('OTP doğrulama hatası', e);
      return AuthResult.failure('Doğrulama başarısız. Tekrar deneyin.');
    }
  }

  /// Google ile giriş yap ve kullanıcı durumunu belirle
  /// Business logic: OAuth flow + profil kontrolü
  Future<AuthResult> signInWithGoogle() async {
    try {
      AppLogger.info('🔐 Google ile giriş başlatılıyor...');

      final success = await _authService.signInWithGoogle(
        redirectUrl: AppConstants.authRedirectUrl,
      );

      if (!success) {
        return AuthResult.failure('Google girişi iptal edildi');
      }

      // OAuth sonrası kullanıcı bilgisi auth state change'den gelecek
      // Bu yüzden burada success döneriz, UI auth state'i dinleyecek
      return AuthResult.success(status: AuthStatus.authenticated);
    } on AppException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Google giriş hatası', e);
      return AuthResult.failure('Google girişi başarısız. Tekrar deneyin.');
    }
  }

  /// Kullanıcının mevcut auth durumunu kontrol et
  /// Business logic: User + Profile kontrolü birlikte
  Future<AuthStatus> checkAuthStatus() async {
    try {
      final user = currentUser;
      
      if (user == null) {
        return AuthStatus.unauthenticated;
      }

      final profile = await _profileService.getProfile(user.id);
      
      if (profile == null) {
        return AuthStatus.needsProfile;
      }

      return AuthStatus.authenticated;
    } catch (e) {
      AppLogger.error('Auth status kontrolü hatası', e);
      return AuthStatus.unauthenticated;
    }
  }

  /// Çıkış yap
  Future<AuthResult> signOut() async {
    try {
      AppLogger.info('👋 Çıkış yapılıyor...');
      
      await _authService.signOut();
      
      return AuthResult.success(status: AuthStatus.unauthenticated);
    } on AppException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      AppLogger.error('Çıkış hatası', e);
      // Çıkış yaparken hata olsa bile kullanıcıyı dışarı at
      return AuthResult.success(status: AuthStatus.unauthenticated);
    }
  }

  /// Email validasyonu (private helper)
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}