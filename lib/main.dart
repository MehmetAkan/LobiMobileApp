import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// Ana giriş noktası
/// Neden değişiklikler:
/// 1. ProviderScope: Riverpod için gerekli wrapper
/// 2. setupServiceLocator: GetIt ile dependency injection
/// 3. Error handling: Uygulama başlatma sırasında oluşabilecek hatalar için
Future<void> main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info('🚀 Uygulama başlatılıyor...');

    // Dependency Injection setup
    // Supabase, Services, Repositories hepsi burada kurulur
    await setupServiceLocator();

    AppLogger.info('✅ Uygulama başarıyla başlatıldı');

    // Riverpod ile uygulamayı başlat
    runApp(
      const ProviderScope(
        child: LobiApp(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.error('❌ Uygulama başlatma hatası', e, stackTrace);
    
    // Hata durumunda basit bir error screen göster
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Uygulama başlatılamadı',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LobiApp extends StatelessWidget {
  const LobiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lobi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppEntry(),
    );
  }
}