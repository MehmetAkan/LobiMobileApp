import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lobi_application/app_entry.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:lobi_application/data/services/local_notification_service.dart';
import 'package:lobi_application/data/services/deep_link_service.dart';

Future<void> main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info('🚀 Uygulama başlatılıyor...');

    // 🗺️ Environment variables yükle - EKLENDI
    await dotenv.load(fileName: ".env");
    AppLogger.info('✅ Environment variables yüklendi');

    // 🔥 Firebase initialize (with duplicate app error handling)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        AppLogger.info('✅ Firebase başlatıldı');
      } else {
        AppLogger.info('✅ Firebase zaten başlatılmış (Dart)');
      }
    } catch (e) {
      // If already initialized natively, this is fine
      if (e.toString().contains('duplicate-app')) {
        AppLogger.info('✅ Firebase zaten başlatılmış (Native)');
      } else {
        rethrow; // Other Firebase errors should be handled
      }
    }

    // 🔔 Initialize local notifications
    await LocalNotificationService().initialize();

    await setupServiceLocator();

    AppLogger.info('✅ Uygulama başarıyla başlatıldı');

    runApp(const ProviderScope(child: LobiApp()));
  } catch (e, stackTrace) {
    AppLogger.error('❌ Uygulama başlatma hatası', e, stackTrace);

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

// Global navigator key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LobiApp extends StatefulWidget {
  const LobiApp({super.key});

  @override
  State<LobiApp> createState() => _LobiAppState();
}

class _LobiAppState extends State<LobiApp> {
  @override
  void initState() {
    super.initState();
    // Deep link service'i başlat
    _initializeDeepLinks();
    // Auth state listener'ı başlat (hesap silme iptali için)
    _setupAuthListener();
  }

  Future<void> _initializeDeepLinks() async {
    try {
      await DeepLinkService().initialize(navigatorKey);
    } catch (e, stackTrace) {
      AppLogger.error('Deep link initialization failed', e, stackTrace);
    }
  }

  /// Auth state değişikliklerini dinle ve hesap silme iptalini kontrol et
  /// Google, Apple, Email - her türlü giriş için çalışır
  void _setupAuthListener() {
    SupabaseManager.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Kullanıcı giriş yaptı - hesap silme talebini iptal et
        AppLogger.info('🔐 User signed in, checking pending deletion...');
        AuthService().checkAndCancelPendingDeletion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, // Deep linking için gerekli
          title: 'Lobi',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // home: const GoogleMapsTestScreen(),
          // home: const LocationTestScreen(),
          home: const AppEntry(),
        );
      },
    );
  }
}
