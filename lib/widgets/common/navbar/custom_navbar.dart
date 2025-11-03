import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import 'package:lobi_application/theme/app_theme.dart'; // BackdropFilter için gerekli

class CustomNavbar extends StatefulWidget {
  final Widget Function(bool isScrolled)? leading;
  final Widget Function(bool isScrolled)? title;
  final List<Widget> Function(bool isScrolled)? actions;
  final ScrollController? scrollController;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double blurThreshold;

  const CustomNavbar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.scrollController,
    this.height,
    this.padding,
    this.blurThreshold = 10.0,
  });

  @override
  State<CustomNavbar> createState() => CustomNavbarState();
}

class CustomNavbarState extends State<CustomNavbar>
    with SingleTickerProviderStateMixin {
  late ScrollController _internalScrollController;
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();

    _internalScrollController = widget.scrollController ?? ScrollController();
    _internalScrollController.addListener(_onScroll);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _blurAnimation =
        Tween<double>(
          begin: 0.0,
          end: 20.0, // BackdropFilter için 10 yeterli
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 5.0, end: 1).animate(
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

  void _onScroll() {
    final offset = _internalScrollController.offset;
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
  }

  @override
  Widget build(BuildContext context) {
    final defaultHeight = widget.height ?? 60.h;
    final defaultPadding =
        widget.padding ?? EdgeInsets.symmetric(horizontal: 15.w);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalHeight = defaultHeight + statusBarHeight;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: Container(
            
              height: totalHeight,
              decoration: BoxDecoration(
            
              ),
              padding: EdgeInsets.only(top: statusBarHeight),
              child: _buildContent(defaultPadding),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.leading != null) widget.leading!(_isScrolled),

          if (widget.title != null) ...[
            if (widget.leading != null) SizedBox(width: 12.w),
            Expanded(child: widget.title!(_isScrolled)),
          ],

          if (widget.actions != null) ...[
            SizedBox(width: 12.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions!(_isScrolled),
            ),
          ],
        ],
      ),
    );
  }

  ScrollController get scrollController => _internalScrollController;
}
