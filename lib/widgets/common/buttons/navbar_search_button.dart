import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavbarSearchButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NavbarSearchButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45.w,   // 40px tasarıma göre
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getNavbarBtnBg(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getNavbarBtnBorder(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.search, // senin ikonun
                size: 22.sp,
                color: AppTheme.getButtonIconColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
