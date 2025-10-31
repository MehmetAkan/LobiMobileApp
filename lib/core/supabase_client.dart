import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseManager {
  static SupabaseManager? _instance;
  
  static SupabaseManager get instance {
    if (_instance == null) {
      throw Exception(
        'SupabaseManager henüz initialize edilmedi. '
        'main() içinde SupabaseManager.init() çağırın.',
      );
    }
    return _instance!;
  }

  final SupabaseClient client;
  
  SupabaseManager._internal(this.client);

  static Future<void> init() async {
    if (_instance != null) {
      AppLogger.warning('SupabaseManager zaten initialize edilmiş');
      return;
    }

    try {
      AppLogger.info('Supabase initialize ediliyor...');
      
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 10,
        ),
        debug: true,
      );

      _instance = SupabaseManager._internal(Supabase.instance.client);
      AppLogger.info('✅ Supabase başarıyla initialize edildi');
    } catch (e, stackTrace) {
      AppLogger.error('Supabase initialize hatası', e, stackTrace);
      rethrow;
    }
  }

  // Dispose (gerekirse)
  static void dispose() {
    _instance = null;
    AppLogger.info('SupabaseManager dispose edildi');
  }
}