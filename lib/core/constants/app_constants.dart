class AppConstants {
  // Supabase
  static const String supabaseUrl = 'https://mavrwjgsfkmdbjlzibbc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hdnJ3amdzZmttZGJqbHppYmJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MjAwODYsImV4cCI6MjA3NzI5NjA4Nn0.Xqgvj_hMAddqtEQN0MWHh3clmSSB20VmGlFlTvd4YnQ';

  // Deep Links
  static const String deepLinkScheme = 'lobi';
  static const String authCallbackPath = 'auth-callback';
  static const String authRedirectUrl = '$deepLinkScheme://$authCallbackPath';

  // Database Tables
  static const String profilesTable = 'profiles';
  static const String eventCategoriesTable = 'event_categories'; // ✨ YENİ
  static const String eventImagesTable = 'event_images';
  static const String eventsTable = 'events';

  // App Info
  static const String appName = 'Lobi';
  static const String appVersion = '1.0.0';
}
