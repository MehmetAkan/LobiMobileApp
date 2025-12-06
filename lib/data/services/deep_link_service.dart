import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/screens/main/events/event_detail_by_slug_screen.dart';

/// Deep Link servisi
///
/// Custom scheme ve Universal Links/App Links'i yönetir:
/// - lobiapp://event/40wwmpxf64 (Custom scheme)
/// - https://go.lobiapp.co/40wwmpxf64 (HTTPS deep link)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  bool _isInitialized = false;

  /// Deep link listener'ları başlat
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      AppLogger.warning('DeepLinkService already initialized');
      return;
    }

    try {
      // Uygulama açıkken gelen linkler
      _appLinks.uriLinkStream.listen(
        (uri) {
          AppLogger.info('📱 Deep link received (app open): $uri');
          _handleDeepLink(navigatorKey, uri);
        },
        onError: (error) {
          AppLogger.error('Deep link stream error', error);
        },
      );

      // Uygulama linkten açıldıysa (initial link)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        AppLogger.info('📱 Deep link received (app launch): $initialUri');
        // Biraz bekle ki uygulama tam başlasın
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(navigatorKey, initialUri);
        });
      }

      _isInitialized = true;
      AppLogger.info('✅ DeepLinkService initialized');
    } catch (e, stackTrace) {
      AppLogger.error('DeepLinkService initialization failed', e, stackTrace);
    }
  }

  /// Deep link'i handle et ve ilgili ekrana yönlendir
  void _handleDeepLink(GlobalKey<NavigatorState> navigatorKey, Uri uri) {
    try {
      AppLogger.info('🔍 Handling deep link: ${uri.toString()}');
      AppLogger.info('   Scheme: ${uri.scheme}');
      AppLogger.info('   Host: ${uri.host}');
      AppLogger.info('   Path: ${uri.path}');
      AppLogger.info('   Segments: ${uri.pathSegments}');

      // Share slug'ı çıkar
      // Format örnekleri:
      // - lobiapp://event/40wwmpxf64 → host: 'event', segments: ['40wwmpxf64']
      // - https://go.lobiapp.co/40wwmpxf64 → host: 'go.lobiapp.co', segments: ['40wwmpxf64']
      String? shareSlug;

      if (uri.pathSegments.isNotEmpty) {
        // Custom scheme: lobiapp://event/SLUG
        // Host = 'event', Path segments = ['SLUG']
        if (uri.scheme == 'lobiapp' && uri.host == 'event') {
          shareSlug = uri.pathSegments.first; // İlk segment slug'dır
        }
        // HTTPS: https://go.lobiapp.co/SLUG
        else if (uri.scheme == 'https' || uri.scheme == 'http') {
          shareSlug = uri.pathSegments.last;
        }
      }

      if (shareSlug == null || shareSlug.isEmpty) {
        AppLogger.warning('⚠️ Share slug not found in URI');
        return;
      }

      // Share slug validasyonu (10 karakter alfanumerik)
      if (!_isValidShareSlug(shareSlug)) {
        AppLogger.warning('⚠️ Invalid share slug format: $shareSlug');
        return;
      }

      AppLogger.info('✅ Valid share slug: $shareSlug');

      // Navigator key geçerli mi kontrol et
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        AppLogger.warning('⚠️ Navigator not ready yet');
        return;
      }

      // Event detail ekranına yönlendir
      navigator.push(
        MaterialPageRoute(
          builder: (_) => EventDetailBySlugScreen(shareSlug: shareSlug!),
        ),
      );

      AppLogger.info('✅ Navigated to EventDetailBySlugScreen');
    } catch (e, stackTrace) {
      AppLogger.error('Deep link handling error', e, stackTrace);
    }
  }

  /// Share slug validasyonu
  /// Format: 10 karakter alfanumerik (örn: 40wwmpxf64)
  bool _isValidShareSlug(String slug) {
    // 10 karakter uzunluğunda olmalı
    if (slug.length != 10) return false;

    // Sadece alfanumerik karakterler
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(slug);
  }

  /// Deep link'i manuel test et (development)
  void testDeepLink(GlobalKey<NavigatorState> navigatorKey, String slug) {
    final testUri = Uri.parse('lobiapp://event/$slug');
    _handleDeepLink(navigatorKey, testUri);
  }
}
