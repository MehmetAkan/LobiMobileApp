import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan geri bildirim (Snackbar / Toast)
/// bileşenleri için temel ayarları tutan config sınıfı.
///
/// İleride:
/// - duration
/// - margin / padding
/// - border radius
/// - elevation
/// gibi değerleri buradan güncelleyebiliriz.
class AppFeedbackConfig {
  /// Snackbar'ın ekranda kalma süresi.
  final Duration duration;

  /// Snackbar'ın ekran kenarlarına göre boşlukları.
  final EdgeInsetsGeometry margin;

  /// Snackbar içindeki padding.
  final EdgeInsetsGeometry padding;

  /// Snackbar köşe yuvarlama değeri.
  final double borderRadius;

  /// Snackbar gölgelendirme (yükseklik).
  final double elevation;

  const AppFeedbackConfig({
    this.duration = const Duration(seconds: 3),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.borderRadius = 20.0,
    this.elevation = 0.0,
  });

  AppFeedbackConfig copyWith({
    Duration? duration,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    double? elevation,
  }) {
    return AppFeedbackConfig(
      duration: duration ?? this.duration,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }

  /// Tüm uygulama için kullanılacak varsayılan config.
  static const AppFeedbackConfig defaultConfig = AppFeedbackConfig();
}
