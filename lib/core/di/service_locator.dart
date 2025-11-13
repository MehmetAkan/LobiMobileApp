import 'package:get_it/get_it.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/data/services/event_image_service.dart';
import 'package:lobi_application/data/services/category_service.dart';
import 'package:lobi_application/data/services/image_picker_service.dart'; // ✨ YENİ
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/data/repositories/profile_repository.dart';
import 'package:lobi_application/data/repositories/event_image_repository.dart';
import 'package:lobi_application/data/repositories/category_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  try {
    AppLogger.info('🔧 Dependency Injection kuruluyor...');

    // 1. Supabase Client (en önce bu olmalı)
    await SupabaseManager.init();
    getIt.registerSingleton(SupabaseManager.instance.client);

    // 2. Services (Supabase ile konuşan katman)
    getIt.registerLazySingleton<AuthService>(() => AuthService());

    getIt.registerLazySingleton<ProfileService>(() => ProfileService());

    getIt.registerLazySingleton<EventImageService>(() => EventImageService());

    getIt.registerLazySingleton<CategoryService>(() => CategoryService());

    getIt.registerLazySingleton<ImagePickerService>(() => ImagePickerService());

getIt.registerLazySingleton<EventService>(() => EventService(getIt()));

    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt<AuthService>(), getIt<ProfileService>()),
    );

    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(getIt<ProfileService>(), getIt<AuthService>()),
    );

    getIt.registerLazySingleton<EventImageRepository>(
      () => EventImageRepository(getIt<EventImageService>()),
    );

    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepository(getIt<CategoryService>()),
    );
    
getIt.registerLazySingleton<EventRepository>(() => EventRepository(getIt(), getIt()));

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
