import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sayfalara pull-to-refresh özelliği kazandıran mixin
///
/// Home ve Explore gibi sayfalar bu mixin'i kullanarak
/// ortak refresh logic'ini paylaşabilir.
mixin RefreshablePageMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  /// Alt sınıflar bu metodu override edip invalidate edilecek provider'ları belirtir
  List<ProviderOrFamily> getProvidersToRefresh();

  /// Alt sınıflar bu metodu override edip refresh sonrası ekstra işlemler yapabilir
  Future<void> onRefreshComplete() async {}

  /// Pull-to-refresh handler
  Future<void> handleRefresh() async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() => _isRefreshing = true);
    }

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Invalidate providers
      final providers = getProvidersToRefresh();
      for (final provider in providers) {
        ref.invalidate(provider);
      }

      // Small delay for UI feedback
      await Future.delayed(const Duration(milliseconds: 100));

      // Refresh complete callback
      await onRefreshComplete();
    } catch (e) {
      debugPrint('⚠️ Refresh error: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  /// Programmatic refresh (tab retap için)
  Future<void> triggerRefresh() async {
    await handleRefresh();
  }
}
