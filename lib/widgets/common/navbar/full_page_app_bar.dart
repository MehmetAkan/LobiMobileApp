import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✨ Status bar için
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

  /// Sağ taraf aksiyon butonu ikonu
  final IconData? actionIcon;

  /// Sağ taraf aksiyon buton background rengi
  final Color? actionIconBackgroundColor;

  /// Sağ taraf aksiyon butonu tıklama olayı
  final VoidCallback? onActionTap;

  /// Sağ taraf aksiyon butonları (Custom)
  final List<Widget>? actions;

  /// Custom geri button callback (null ise Navigator.pop kullanır)
  final VoidCallback? onBackPressed;

  /// AppBar yüksekliği
  final double? height;

  /// Başlık gözükme threshold'u (scroll offset)
  final double titleThreshold;

  /// Blur başlama threshold'u
  final double blurThreshold;

  /// Event detail için özel back button kullanılsın mı?
  final bool useEventBackButton;

  const FullPageAppBar({
    super.key,
    required this.title,
    this.scrollController,
    this.style = AppBarStyle.dark,
    this.actionIcon,
    this.actionIconBackgroundColor,
    this.onActionTap,
    this.actions,
    this.onBackPressed,
    this.height,
    this.titleThreshold = 20.0,
    this.blurThreshold = 3.0,
    this.useEventBackButton = false,
  });

  @override
  State<FullPageAppBar> createState() => _FullPageAppBarState();
}

class _FullPageAppBarState extends State<FullPageAppBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _internalScrollController;
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;

  // Title animations
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _titleScaleAnimation;

  bool _isScrolled = false;
  double _titleOpacity = 0.0;
  double _titleScale = 1.0;
  bool _statusBarStyleSet = false;

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

    // Title opacity animation (Dark style için)
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Title scale animation (Secondary style için)
    _titleScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Status bar stilini sadece bir kez ayarla (context hazır olduktan sonra)
    if (!_statusBarStyleSet) {
      _setStatusBarStyle();
      _statusBarStyleSet = true;
    }
  }

  @override
  void dispose() {
    // Not: Status bar stil ayarını dispose'da yapmıyoruz çünkü:
    // 1. dispose() sırasında context artık geçerli değil
    // 2. Her FullPageAppBar zaten initState'te doğru stili ayarlıyor
    // 3. Bir sonraki sayfa kendi status bar ayarını yapacak

    _animationController.dispose();
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    } else {
      _internalScrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _setStatusBarStyle() {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    switch (widget.style) {
      case AppBarStyle.dark:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // ✨ Beyaz
            statusBarBrightness: Brightness.dark, // iOS için
          ),
        );
        break;
      case AppBarStyle.secondary:
        // Secondary style → Dark mode'da beyaz, light mode'da siyah ikonlar
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode
                ? Brightness
                      .light // Dark mode: Beyaz ikonlar
                : Brightness.dark, // Light mode: Siyah ikonlar
            statusBarBrightness: isDarkMode
                ? Brightness
                      .dark // iOS için dark mode
                : Brightness.light, // iOS için light mode
          ),
        );
        break;
    }
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

    // Title opacity threshold (Sadece Dark style için)
    if (widget.style == AppBarStyle.dark) {
      final titleProgress = (offset / widget.titleThreshold).clamp(0.0, 1.0);
      if (titleProgress != _titleOpacity) {
        setState(() {
          _titleOpacity = titleProgress;
        });
      }
    }

    // Title scale threshold (Sadece Secondary style için)
    if (widget.style == AppBarStyle.secondary) {
      // 0.0 -> 1.0 arası progress
      final scaleProgress = (offset / 50.0).clamp(0.0, 1.0);
      // 1.0 -> 0.9 arası scale (küçülme)
      final newScale = 1.0 - (scaleProgress * 0.1);

      if (newScale != _titleScale) {
        setState(() {
          _titleScale = newScale;
        });
      }
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
        return AppTheme.getAppBarButtonBgColorSecondary(context);
    }
  }

  Color _getEventButtonBgColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getEventAppBarButtonBg(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarButtonBgColorSecondary(context);
    }
  }

  Color _getEventButtonBorderColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getEventAppBarButtonBorder(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarButtonBorderColorSecondary(context);
    }
  }

  Color _getHeadTextColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getAppBarTextColor(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarTextColorSecondary(context);
    }
  }

  /// Style'a göre button border color
  Color _getButtonBorderColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getAppBarButtonBorder(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarButtonBorderColorSecondary(context);
    }
  }

  Color _getButtonTextColor(BuildContext context) {
    switch (widget.style) {
      case AppBarStyle.dark:
        return AppTheme.getAppBarTextColor(context);
      case AppBarStyle.secondary:
        return AppTheme.getAppBarTextColorSecondary(context);
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
          widget.useEventBackButton
              ? _buildEventBackButton(context)
              : _buildBackButton(context),
          SizedBox(width: 10.w),
          // Orta - Başlık (Dinamik)
          Expanded(
            child: widget.style == AppBarStyle.dark
                // Dark Style: Fade In/Out
                ? AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _titleOpacity,
                    child: _buildTitleText(context),
                  )
                // Secondary Style: Scale Down
                : Transform.scale(
                    scale: _titleScale,
                    child: _buildTitleText(context),
                  ),
          ),

          // Sağ - Aksiyon Butonları (Dinamik)
          if (widget.actionIcon != null)
            _buildActionButton(context)
          else if (widget.actions != null && widget.actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
          else
            // Boşluk dengesi için
            SizedBox(width: 45.w),
        ],
      ),
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Center(
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: _getHeadTextColor(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
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
                size: 22.sp,
                color: _getButtonTextColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventBackButton(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onBackPressed ?? () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: _getEventButtonBgColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getEventButtonBorderColor(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.chevronLeft400,
                size: 22.sp,
                color: _getButtonTextColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onActionTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.actionIconBackgroundColor ??
                  _getButtonBgColor(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getButtonBorderColor(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                widget.actionIcon,
                size: 22.sp,
                color: widget.actionIconBackgroundColor != null
                    ? AppTheme.white
                    : _getButtonTextColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
