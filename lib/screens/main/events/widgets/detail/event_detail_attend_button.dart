import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


/// ```
class EventDetailAttendButton extends StatelessWidget {
  final bool isAttending;
  final bool isFull;
  final VoidCallback onPressed;

  const EventDetailAttendButton({
    super.key,
    required this.isAttending,
    required this.isFull,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Etkinlik doluysa
    if (isFull) {
      return _buildButton(
        context: context,
        label: 'Etkinlik Dolu',
        icon: LucideIcons.userX400,
        backgroundColor: AppTheme.white.withValues(alpha: 0.1),
        textColor: AppTheme.white.withValues(alpha: 0.4),
        onTap: null, // Disabled
      );
    }

    // Kullanıcı katıldıysa
    if (isAttending) {
      return _buildButton(
        context: context,
        label: 'Katılıyor',
        icon: LucideIcons.badgeCheck400,
        backgroundColor: AppTheme.green900.withValues(alpha: 0.2),
        textColor: AppTheme.green900,
        borderColor: AppTheme.green900.withValues(alpha: 0.3),
        onTap: onPressed,
      );
    }

    // Henüz katılmadıysa
    return _buildButton(
      context: context,
      label: 'Katıl',
      icon: LucideIcons.userPlus400,
      backgroundColor: AppTheme.purple900,
      textColor: AppTheme.white,
      onTap: onPressed,
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: textColor,
              ),
              SizedBox(width: 10.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}