import 'package:flutter/material.dart';
import 'package:lobi_application/screens/auth/authentication_screen.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/screens/auth/mail_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ParafoniApp());
}

class ParafoniApp extends StatelessWidget {
  const ParafoniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parafoni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthenticationScreen(),
    );
  }
}
