import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// Uygulama genelinde kullanılan branded RefreshIndicator
///
/// Tüm pull-to-refresh işlemleri için standart tasarım sağlar.
/// Tasarım değişikliği sadece bu dosyadan yapılır.
///
/// Örnek kullanım:
/// ```dart
/// AppRefreshIndicator(
///   onRefresh: _handleRefresh,
///   child: ListView(...),
/// )
/// ```
class AppRefreshIndicator extends StatelessWidget {
  /// Refresh callback - async olmalı
  final Future<void> Function() onRefresh;

  /// Refresh indicator altındaki içerik (genelde ScrollView)
  final Widget child;

  /// Loading indicator'ın üstten mesafesi (navbar için)
  /// Default: 80.h (navbar yüksekliği)
  final double? displacement;

  /// Custom loading rengi (opsiyonel)
  /// Default: AppTheme.purple700
  final Color? color;

  /// Custom background rengi (opsiyonel)
  /// Default: AppTheme.white
  final Color? backgroundColor;

  /// Stroke width (indicator kalınlığı)
  /// Default: 2.5
  final double? strokeWidth;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,

      // Brand colors
      color: color ?? AppTheme.purple700,
      backgroundColor: backgroundColor ?? AppTheme.white,

      // UI tweaks
      displacement: displacement ?? 80.h,
      strokeWidth: strokeWidth ?? 2.5,

      // Smooth easing
      edgeOffset: 0,

      child: child,
    );
  }
}
