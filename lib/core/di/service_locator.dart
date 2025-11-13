import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';

import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/data/services/event_image_service.dart';
import 'package:lobi_application/data/services/category_service.dart';
import 'package:lobi_application/data/services/image_picker_service.dart';

import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/data/repositories/profile_repository.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/repositories/event_image_repository.dart';
import 'package:lobi_application/data/repositories/category_repository.dart';

final getIt = GetIt.instance;

/// Uygulama genelinde kullanılacak root ScaffoldMessenger key.
/// MaterialApp içinde [scaffoldMessengerKey] olarak kullanılacak.
///
/// Bu key, [AppFeedbackService] tarafından da kullanılır.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future setupServiceLocator() async {
  try {
    AppLogger.info(' Dependency Injection kuruluyor...');

    // 1. Supabase Client (en önce bu olmalı)
    await SupabaseManager.init();
    getIt.registerSingleton(SupabaseManager.instance.client);

    // 2. Services (Supabase ile konuşan katman)
    getIt.registerLazySingleton(() => AuthService());
    getIt.registerLazySingleton(() => ProfileService());
    getIt.registerLazySingleton(() => EventImageService());
    getIt.registerLazySingleton(() => CategoryService());
    getIt.registerLazySingleton(() => ImagePickerService());
    getIt.registerLazySingleton(() => EventService(getIt()));

    // 3. Repositories
    getIt.registerLazySingleton(
      () => AuthRepository(getIt(), getIt()),
    );
    getIt.registerLazySingleton(
      () => ProfileRepository(getIt(), getIt()),
    );
    getIt.registerLazySingleton(
      () => EventImageRepository(getIt()),
    );
    getIt.registerLazySingleton(
      () => CategoryRepository(getIt()),
    );
    getIt.registerLazySingleton(
      () => EventRepository(getIt(), getIt()),
    );

    // 4. Global Feedback Service
    getIt.registerLazySingleton<AppFeedbackService>(
      () => AppFeedbackService(rootScaffoldMessengerKey),
    );

    AppLogger.info('✅ Dependency Injection kuruldu');
  } catch (e, stackTrace) {
    AppLogger.error('DI setup hatası', e, stackTrace);
    rethrow;
  }
}

/// GetIt'i temizle (testler için)
Future resetServiceLocator() async {
  await getIt.reset();
  AppLogger.info(' Service Locator temizlendi');
}
