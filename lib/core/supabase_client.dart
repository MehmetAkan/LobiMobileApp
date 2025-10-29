import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  // Tekil instance için singleton mantığı
  static final SupabaseManager _instance = SupabaseManager._internal();
  factory SupabaseManager() => _instance;
  SupabaseManager._internal();

  // Supabase client'a buradan erişeceğiz
  late final SupabaseClient client;

  // Bunu main()'de bir kere çağıracağız
  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://mavrwjgsfkmdbjlzibbc.supabase.co', // SUPABASE_URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdnJ3amdzZmttZGJqbHppYmJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MjAwODYsImV4cCI6MjA3NzI5NjA4Nn0.Xqgvj_hMAddqtEQN0MWHh3clmSSB20VmGlFlTvd4YnQ', // SUPABASE_ANON_KEY
      // opsiyonel: auth ayarlarını burada ileride özelleştirebiliriz
    );

    client = Supabase.instance.client;
  }
}
