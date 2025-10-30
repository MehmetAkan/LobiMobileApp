
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  // Singleton
  static final SupabaseManager _instance = SupabaseManager._internal();
  factory SupabaseManager() => _instance;
  SupabaseManager._internal();

  late final SupabaseClient client;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://mavrwjgsfkmdbjlzibbc.supabase.co', // <- Supabase Project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdnJ3amdzZmttZGJqbHppYmJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MjAwODYsImV4cCI6MjA3NzI5NjA4Nn0.Xqgvj_hMAddqtEQN0MWHh3clmSSB20VmGlFlTvd4YnQ',              // <- anon/public key
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

    // initialize bittikten sonra client'i saklıyoruz
    client = Supabase.instance.client;
  }
}
