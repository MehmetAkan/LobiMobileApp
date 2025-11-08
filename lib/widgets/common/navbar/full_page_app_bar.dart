import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// AppBar stilleri - Sayfa bazlı seçilebilir
enum AppBarStyle {
  /// Varsayılan stil - Daha belirgin blur ve border
  dark,

  /// Alternatif stil - Daha subtle görünüm
  secondary,
}

class FullPageAppBar extends StatefulWidget {
  /// Başlık metni
  final String title;

  /// Scroll controller - başlık opacity için
  final ScrollController? scrollController;

  /// AppBar stili
  final AppBarStyle style;

  /// Sağ taraf aksiyon butonları
  final List<Widget>? actions;

  /// Custom geri button callback (null ise Navigator.pop kullanır)
  final VoidCallback? onBackPressed;

  /// AppBar yüksekliği
  final double? height;

  /// Başlık gözükme threshold'u (scroll offset)
  final double titleThreshold;

  /// Blur başlama threshold'u
  final double blurThreshold;

  const FullPageAppBar({
    super.key,
    required this.title,
    this.scrollController,
    this.style = AppBarStyle.dark,
    this.actions,
    this.onBackPressed,
    this.height,
    this.titleThreshold = 50.0,
    this.blurThreshold = 3.0,
  });

  @override
  State<FullPageAppBar> createState() => _FullPageAppBarState();
}

class _FullPageAppBarState extends State<FullPageAppBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _internalScrollController;
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  late Animation<double> _titleOpacityAnimation;

  bool _isScrolled = false;
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    _internalScrollController = widget.scrollController ?? ScrollController();
    _internalScrollController.addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Blur animation (custom_navbar'dan alındı)
    _blurAnimation =
        Tween<double>(
          begin: _getBlurAmount(false),
          end: _getBlurAmount(true),
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );

    // Title opacity animation
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    } else {
      _internalScrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  double _getBlurAmount(bool isScrolled) {
    if (!isScrolled) return 3.0;

    switch (widget.style) {
      case AppBarStyle.dark:
        return 1.5;
      case AppBarStyle.secondary:
        return 1.5;
    }
  }

  /// Scroll listener
  void _onScroll() {
    final offset = _internalScrollController.offset;

    // Blur threshold
    final shouldShowBlur = offset > widget.blurThreshold;
    if (shouldShowBlur != _isScrolled) {
      setState(() {
        _isScrolled = shouldShowBlur;
      });

      if (shouldShowBlur) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Title opacity threshold
    final titleProgress = (offset / widget.titleThreshold).clamp(0.0, 1.0);
    if (titleProgress != _titleOpacity) {
      setState(() {
        _titleOpacity = titleProgress;
      });
    }
  }

  /// Style'a göre background opacity değerleri
  List<double> _getBackgroundOpacities() {
    switch (widget.style) {
      case AppBarStyle.dark:
        return [0.01, 0.4, .9];
      case AppBarStyle.secondary:
        return [0.01, 0.4, .9];
    }
  }

  /// Style'a göre border opacity
  double _getBorderOpacity() {
    switch (widget.style) {
      case AppBarStyle.dark:
        return 0;
      case AppBarStyle.secondary:
        return 0;
    }
  }

  /// Style'a göre button background color
  Color _getButtonBgColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getAppBarButtonBg(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarButtonBg(context);
    }
  }

  /// Style'a göre button border color
  Color _getButtonBorderColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getAppBarButtonBorder(context);
      case AppBarStyle.secondary:
        return AppTheme.getButtonIconBorder(context);
    }
  }

  LinearGradient _getAppBarGradient(BuildContext context) {
    final opacities = [1.0, 0.7, 0.0];

    switch (widget.style) {
      case AppBarStyle.dark:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.getAppBarBg(context).withOpacity(opacities[0]),
            AppTheme.getAppBarBg(context).withOpacity(opacities[1]),
            AppTheme.getAppBarBg(context).withOpacity(opacities[2]),
          ],
        );

      case AppBarStyle.secondary:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.getButtonIconBorder(context).withOpacity(opacities[0]),
            AppTheme.getButtonIconBorder(context).withOpacity(opacities[1]),
            AppTheme.getButtonIconBorder(context).withOpacity(opacities[2]),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultHeight = widget.height ?? 60.h;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalHeight = defaultHeight + statusBarHeight;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final opacities = _getBackgroundOpacities();

        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: Container(
              height: totalHeight,
              decoration: BoxDecoration(
                gradient: _getAppBarGradient(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.getNavbarBorder(
                      context,
                    ).withOpacity(_getBorderOpacity()),
                    width: 0.7,
                  ),
                ),
              ),
              padding: EdgeInsets.only(top: statusBarHeight),
              child: _buildContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol - Geri Button (Sabit)
          _buildBackButton(context),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _titleOpacity,
              child: Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getAppBarTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Sağ - Aksiyon Butonları (Dinamik)
          if (widget.actions != null && widget.actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
          else
            // Boşluk dengesi için
            SizedBox(width: 45.w),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: 45.w,
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: _getButtonBgColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getButtonBorderColor(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.chevronLeft400,
                size: 25.sp,
                color: AppTheme.getAppBarButtonColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
