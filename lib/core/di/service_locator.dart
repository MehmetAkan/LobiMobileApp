import 'package:get_it/get_it.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/data/repositories/profile_repository.dart';

final getIt = GetIt.instance;


Future<void> setupServiceLocator() async {
  try {
    AppLogger.info('🔧 Dependency Injection kuruluyor...');

    // 1. Supabase Client (en önce bu olmalı)
    await SupabaseManager.init();
    getIt.registerSingleton(SupabaseManager.instance.client);

    // 2. Services (Supabase ile konuşan katman)
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(),
    );

    getIt.registerLazySingleton<ProfileService>(
      () => ProfileService(),
    );

    // 3. Repositories (Business logic katmanı)
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        getIt<AuthService>(),
        getIt<ProfileService>(),
      ),
    );

    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(
        getIt<ProfileService>(),
        getIt<AuthService>(),
      ),
    );

    AppLogger.info('✅ Dependency Injection kuruldu');
  } catch (e, stackTrace) {
    AppLogger.error('DI setup hatası', e, stackTrace);
    rethrow;
  }
}

/// GetIt'i temizle (testler için)
Future<void> resetServiceLocator() async {
  await getIt.reset();
  AppLogger.info('🧹 Service Locator temizlendi');
}