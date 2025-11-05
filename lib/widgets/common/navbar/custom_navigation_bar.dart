import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'dart:ui';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double? height;
  final double blurAmount;
  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.height,
    this.blurAmount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = 70.h;
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.getnNavigationBg(context).withOpacity(0),
              AppTheme.getnNavigationBg(context).withOpacity(0.5),
              AppTheme.getnNavigationBg(context).withOpacity(1),
            ],
          ),
          border: Border(
            top: BorderSide(color: AppTheme.getNavbarBorder(context), width: 1),
          ),
        ),
        padding: EdgeInsets.only(bottom: 20, top: 0, left: 20, right: 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            height: totalHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.getnNavigationBg(context).withOpacity(0.2),
                  AppTheme.getnNavigationBg(context).withOpacity(0.5),
                  AppTheme.getnNavigationBg(context).withOpacity(1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.zinc800.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: AppTheme.getNavbarBorder(context),
                  width: 1.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const itemCount = 4;
                final itemWidth = constraints.maxWidth / itemCount;
                const factor = 1.11;
                final desiredBgWidth = itemWidth * factor;
                const safeInset = 3.0;
                final maxBgWidth = constraints.maxWidth - safeInset * 2;
                final bgWidth = desiredBgWidth
                    .clamp(0.0, maxBgWidth)
                    .toDouble();
                final itemCenter = itemWidth * currentIndex + itemWidth / 2;
                final minCenter = safeInset + bgWidth / 2;
                final maxCenter =
                    constraints.maxWidth - safeInset - bgWidth / 2;
                final centerX = itemCenter
                    .clamp(minCenter, maxCenter)
                    .toDouble();
                final left = centerX - bgWidth / 2;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: 0,
                      bottom: 0,
                      left: left,
                      child: Container(
                        width: bgWidth,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: AppTheme.getNavbarBtnBorder(context),
                            width: 0.8,
                          ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: AppTheme.dark_zinc800.withOpacity(0.1),
                          //     blurRadius: 10,
                          //     offset: const Offset(0, 3),
                          //   ),
                          // ],
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: _buildNavItem(
                              context: context,
                              index: 0,
                              activeIcon:
                                  'assets/images/system/navigation/home-active-icon.svg',
                              inactiveIcon:
                                  'assets/images/system/navigation/home-icon.svg',
                              label: 'Ana Sayfa',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            context: context,
                            index: 1,
                            activeIcon:
                                'assets/images/system/navigation/discovery-active-icon.svg',
                            inactiveIcon:
                                'assets/images/system/navigation/discovery-icon.svg',
                            label: 'Keşfet',
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            context: context,
                            index: 2,
                            activeIcon:
                                'assets/images/system/navigation/activity-active-icon.svg',
                            inactiveIcon:
                                'assets/images/system/navigation/activity-icon.svg',
                            label: 'Etkinlik',
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: _buildNavItem(
                              context: context,
                              index: 3,
                              activeIcon:
                                  'assets/images/system/navigation/profile-active-icon.svg',
                              inactiveIcon:
                                  'assets/images/system/navigation/profile-icon.svg',
                              label: 'Profil',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String activeIcon,
    required String inactiveIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: SvgPicture.asset(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey('$index-$isActive'),
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  isActive
                      ? AppTheme.purple900
                      : AppTheme.getTextDescColor(context),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppTheme.purple900
                    : AppTheme.getTextDescColor(context),
                height: 1.2,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
