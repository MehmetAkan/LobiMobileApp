import 'package:flutter/material.dart';
import 'package:lobi_application/state/auth_controller.dart';
import 'package:lobi_application/screens/auth/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
/// Bu widget uygulamanın gerçek giriş noktası.
/// - Supabase zaten main.dart içinde initialize edilmiş olacak.
/// - Uygulama deep link ile de açılsa, burada hemen kontrol edip
///   doğru ekrana yönlendiriyoruz.
/// - Router'ı lobi://auth-callback gibi garip bir path ile bırakmıyoruz.
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

    // 1. İlk açılışta kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AuthController().checkSessionAndRedirect(context: context);
      if (mounted) {
        setState(() {
          _checked = true;
        });
      }
    });

    // 2. OAuth dönüşü gibi sonradan login olursa tekrar yönlendir
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event; // SignedIn, SignedOut, etc.

      if (event == AuthChangeEvent.signedIn && mounted) {
        // Kullanıcı yeni giriş yaptı demektir
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



