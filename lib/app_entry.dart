import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/providers/auth_provider.dart';
import 'package:lobi_application/providers/connectivity_provider.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/screens/auth/welcome_screen.dart';
import 'package:lobi_application/screens/auth/username_setup_screen.dart';
import 'package:lobi_application/screens/auth/create_profile_screen.dart';
import 'package:lobi_application/screens/main/main_navigation_screen.dart';

/// App Entry Point
/// Neden ConsumerWidget: Riverpod provider'ları dinlemek için
/// Auth state'e göre otomatik ekran yönlendirmesi yapar
class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state'i dinle
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Loading: Auth state yüklenirken
      loading: () {
        AppLogger.debug('Auth state yükleniyor...');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      // Error: Auth state yüklenirken hata
      error: (error, stack) {
        AppLogger.error('Auth state hatası', error, stack);
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Bir hata oluştu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // State'i yeniden yükle
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        );
      },

      // Data: Auth state yüklendi
      data: (user) {
        // 1. Kullanıcı yoksa -> Welcome Screen
        if (user == null) {
          AppLogger.debug('Kullanıcı yok -> Welcome Screen');
          return const WelcomeScreen();
        }

        // 2. Kullanıcı var -> Profil kontrolü
        AppLogger.debug('Kullanıcı var: ${user.email} -> Profil kontrolü');
        final profileState = ref.watch(currentUserProfileProvider);
        final networkStatus = ref.watch(connectivityProvider);

        return profileState.when(
          loading: () {
            AppLogger.debug('Profil yükleniyor...');
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
          error: (error, stack) {
            // If offline, show waiting screen instead of error
            if (networkStatus == NetworkStatus.offline) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'İnternet bağlantısı bekleniyor...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bağlantı sağlandığında otomatik devam edilecek',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // If online but error, go to CreateProfile (might be missing profile)
            AppLogger.error('Profil yükleme hatası', error, stack);
            return const CreateProfileScreen();
          },
          data: (profile) {
            if (profile == null) {
              AppLogger.debug('Profil yok -> Create Profile Screen');
              return const CreateProfileScreen();
            }

            // Username kontrolü
            if (profile.username == null || profile.username!.isEmpty) {
              AppLogger.debug('Username yok -> Username Setup Screen');
              return const UsernameSetupScreen();
            }

            AppLogger.debug('Profil var: ${profile.fullName} -> Home Screen');
            return const MainNavigationScreen();
          },
        );
      },
    );
  }
}
