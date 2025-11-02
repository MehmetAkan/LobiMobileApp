import 'package:flutter/material.dart';

/// Scroll durumunu yöneten mixin
/// Kullanım: State sınıfına `with ScrollablePageMixin` ekle
mixin ScrollablePageMixin<T extends StatefulWidget> on State<T> {
  // ScrollController - alt sınıf override edebilir
  ScrollController? _scrollController;
  ScrollController get scrollController => _scrollController ??= ScrollController();
  
  // Scroll durumu
  bool _isScrolled = false;
  bool get isScrolled => _isScrolled;
  
  // Scroll threshold (ne kadar scroll sonra tetiklensin)
  double get scrollThreshold => 10.0;
  
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    if (_scrollController != null) {
      _scrollController!.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    final offset = scrollController.offset;
    final shouldBeScrolled = offset > scrollThreshold;
    
    if (shouldBeScrolled != _isScrolled) {
      setState(() {
        _isScrolled = shouldBeScrolled;
      });
      
      // Alt sınıf için callback
      onScrollStateChanged(_isScrolled);
    }
  }
  
  /// Override edilerek scroll durumu değişikliğinde özel işlemler yapılabilir
  void onScrollStateChanged(bool isScrolled) {}
}