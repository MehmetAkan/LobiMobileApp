import 'package:flutter/material.dart';

/// AppRestartWidget - Phoenix Pattern Implementation
///
/// Bu widget, uygulamanın tüm state'ini temizleyip yeniden başlatmak için kullanılır.
/// Büyük projelerde (Instagram, Airbnb, etc.) kullanılan standard bir pattern'dir.
///
/// Kullanım:
/// ```dart
/// // main.dart içinde MaterialApp'i wrap et:
/// AppRestartWidget(
///   child: MaterialApp(...),
/// )
///
/// // Herhangi bir yerden restart tetikle:
/// AppRestartWidget.restartApp(context);
/// ```
///
/// Nasıl Çalışır:
/// - Global bir Key ile widget tree'yi track eder
/// - restartApp() çağrıldığında key değişir
/// - Key değişince Flutter widget tree'yi tamamen yeniden oluşturur
/// - Tüm state, provider'lar, navigation stack sıfırlanır
class AppRestartWidget extends StatefulWidget {
  final Widget child;

  const AppRestartWidget({super.key, required this.child});

  /// Uygulamayı restart eder
  ///
  /// Context'ten parent AppRestartWidget'ı bulur ve restart method'unu çağırır
  static void restartApp(BuildContext context) {
    debugPrint('🔄 AppRestartWidget.restartApp() called');
    final state = context.findAncestorStateOfType<_AppRestartWidgetState>();

    if (state == null) {
      debugPrint('❌ _AppRestartWidgetState bulunamadı!');
    } else {
      debugPrint('✅ _AppRestartWidgetState bulundu, restart ediliyor...');
      state.restartApp();
    }
  }

  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key _key = UniqueKey();

  /// Widget tree'yi yeniden oluşturur
  void restartApp() {
    debugPrint(
      '🔄 _AppRestartWidgetState.restartApp() - Key değiştiriliyor...',
    );
    setState(() {
      _key = UniqueKey(); // Yeni key = yeni widget tree
    });
    debugPrint('✅ Key değiştirildi - app restart edildi!');
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
