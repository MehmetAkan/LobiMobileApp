import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Navbar filter button widget
/// isActive parametresi ile seçili/seçili değil durumunu gösterir
class NavbarFilterButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive; // Filtre aktif mi? (Tüm Etkinlikler dışında bir şey seçili mi?)

  const NavbarFilterButton({
    super.key,
    this.onTap,
    this.isActive = false, // Varsayılan olarak aktif değil
  });

  @override
  Widget build(BuildContext context) {
    // Aktif/pasif durumlara göre renkler
    final backgroundColor = isActive
        ? AppTheme.getNavbarBtnActiveBg(context) // Aktif arka plan (açık mor)
        : AppTheme.getNavbarBtnBg(context); // Normal arka plan
    
    final borderColor = isActive
        ? AppTheme.getNavbarBtnActiveBg(context) // Aktif border (mor)
        : AppTheme.getNavbarBtnBorder(context); // Normal border
    
    final iconColor = isActive
        ? AppTheme.getNavbarBtnActiveText(context) // Aktif icon (mor)
        : AppTheme.getButtonIconColor(context); // Normal icon

    return SizedBox(
      width: 45.w,
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.listFilter400,
                size: 22.sp,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}