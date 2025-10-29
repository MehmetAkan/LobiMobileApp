import 'package:flutter/material.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'core/supabase_client.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/screens/auth/welcome_screen.dart';

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
      home: const WelcomeScreen(),
    );
  }
}
