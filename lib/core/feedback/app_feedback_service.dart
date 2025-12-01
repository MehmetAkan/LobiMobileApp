import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_feedback_config.dart';
import 'app_feedback_type.dart';

class AppFeedbackService {
  AppFeedbackService(
    this._scaffoldMessengerKey, {
    AppFeedbackConfig config = AppFeedbackConfig.defaultConfig,
  }) : _config = config;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final AppFeedbackConfig _config;

  /// Genel metot: tip vererek mesaj gösterir.
  void show(String message, {AppFeedbackType type = AppFeedbackType.info}) {
    _show(message, type);
  }

  /// Success mesajı: Örn. "Etkinlik başarıyla oluşturuldu"
  void showSuccess(String message) {
    _show(message, AppFeedbackType.success);
  }

  /// Error mesajı: Örn. "Bir hata oluştu, lütfen tekrar deneyin"
  void showError(String message) {
    _show(message, AppFeedbackType.error);
  }

  /// Info mesajı: Bilgilendirme amaçlı.
  void showInfo(String message) {
    _show(message, AppFeedbackType.info);
  }

  /// Warning mesajı: Uyarı / dikkat gerektiren durumlar.
  void showWarning(String message) {
    _show(message, AppFeedbackType.warning);
  }

  void _show(String message, AppFeedbackType type) {
    final messengerState = _scaffoldMessengerKey.currentState;
    final context = _scaffoldMessengerKey.currentContext;

    if (messengerState == null || context == null) {
      debugPrint(
        'AppFeedbackService: ScaffoldMessengerState veya context null, '
        'mesaj gösterilemedi: $message',
      );
      return;
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bgColor = _backgroundColorFor(type, colors);
    final fgColor = _foregroundColorFor(type, colors);
    final iconData = _iconFor(type);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors
          .transparent, // dış Snackbar şeffaf, asıl renk içerideki Container’da
      elevation: 0,
      margin: _config.margin,
      duration: _config.duration,
      content: Container(
        padding: _config.padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_config.borderRadius),
          boxShadow: _config.elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: _config.elevation,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(iconData, size: 22, color: fgColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Önceki snackbar'ları temizleyip tek bir güncel mesaj gösteriyoruz
    messengerState.clearSnackBars();
    messengerState.showSnackBar(snackBar);
  }

  Color _backgroundColorFor(AppFeedbackType type, ColorScheme colors) {
    switch (type) {
      case AppFeedbackType.success:
        // Başarı: genelde aksiyon rengi / secondary
        return AppTheme.green500;
      case AppFeedbackType.error:
        return AppTheme.red700;
      case AppFeedbackType.warning:
        return AppTheme.orange600;
      case AppFeedbackType.info:
      default:
        return AppTheme.purple900;
    }
  }

  Color _foregroundColorFor(AppFeedbackType type, ColorScheme colors) {
    switch (type) {
      case AppFeedbackType.success:
        return AppTheme.white;
      case AppFeedbackType.error:
        return AppTheme.white;
      case AppFeedbackType.warning:
        return AppTheme.white;
      case AppFeedbackType.info:
      default:
        return AppTheme.white;
    }
  }

  IconData _iconFor(AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.success:
        return LucideIcons.badgeCheck400;
      case AppFeedbackType.error:
        return LucideIcons.badgeAlert400;
      case AppFeedbackType.warning:
        return LucideIcons.badgeAlert400;
      case AppFeedbackType.info:
      default:
        return LucideIcons.badgeInfo400;
    }
  }
}
