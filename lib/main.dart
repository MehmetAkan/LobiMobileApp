import 'package:flutter/material.dart';
import 'package:lobi_application/app_entry.dart';
import 'core/supabase_client.dart';
import 'package:lobi_application/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase'i başlat
  await SupabaseManager().init();
  

  runApp(const LobiApp());
}

class LobiApp extends StatelessWidget {
  const LobiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lobi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // senin mevcut theme yapın neyse
      home: const AppEntry(),
    );
  }
}
