import 'package:flutter/material.dart';
import 'package:lobi_application/state/auth_controller.dart';
import 'package:lobi_application/screens/auth/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _checked = false;
  StreamSubscription<AuthState>? _authSub;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AuthController().checkSessionAndRedirect(context: context);
      if (mounted) {
        setState(() {
          _checked = true;
        });
      }
    });

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event; // SignedIn, SignedOut, etc.

      if (event == AuthChangeEvent.signedIn && mounted) {
        await AuthController().checkSessionAndRedirect(context: context);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const WelcomeScreen();
  }
}



