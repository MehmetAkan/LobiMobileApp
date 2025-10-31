import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lobi_application/data/services/auth_service.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/screens/auth/welcome_screen.dart';
import 'package:lobi_application/screens/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthGateStatus {
  loading,
  needsAuth,
  needsProfile,
  ready,
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  AuthGateStatus _status = AuthGateStatus.loading;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    // 1. App açıldığında mevcut durumu çöz
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _resolveAuthState();
    });

    // 2. Supabase auth eventlerini dinle
    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (!mounted) return;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.passwordRecovery:
          await _resolveAuthState();
          break;

        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          setState(() {
            _status = AuthGateStatus.needsAuth;
          });
          break;

        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Kullanıcı oturumu, profil durumu vs her şeyi burada çözüyoruz
  Future<void> _resolveAuthState() async {
    final authService = AuthService();
    final profileService = ProfileService();

    final user = authService.currentUser;

    // 1. Kullanıcı yoksa -> needsAuth
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _status = AuthGateStatus.needsAuth;
      });
      return;
    }

    // 2. Kullanıcı var -> profil var mı?
    try {
      final profile = await profileService.getMyProfile();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _status = AuthGateStatus.needsProfile;
        });
      } else {
        setState(() {
          _status = AuthGateStatus.ready;
        });
      }
    } catch (e) {
      // profil sorgusunda hata olursa şimdilik konservatif davran:
      // profil eksikmiş gibi kabul et -> onboarding'e gönder
      if (!mounted) return;
      setState(() {
        _status = AuthGateStatus.needsProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AuthGateStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AuthGateStatus.needsAuth:
        return const WelcomeScreen();

      case AuthGateStatus.needsProfile:
        return const CreateProfileScreen();

      case AuthGateStatus.ready:
        return const HomeScreen();
    }
  }
}
