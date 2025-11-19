import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

enum ActionButtonType { standard, featured }

class EventDetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ActionButtonType type;

  const EventDetailActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.type = ActionButtonType.standard,
  });

  @override
  Widget build(BuildContext context) {
    final isFeatured = type == ActionButtonType.featured;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 55.h,
          decoration: BoxDecoration(
            color: isFeatured
                ? AppTheme.white
                : AppTheme.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isFeatured
                  ? AppTheme.white
                  : AppTheme.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isFeatured ? AppTheme.black800 : AppTheme.white,
              ),
              SizedBox(height: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isFeatured ? AppTheme.black800 : AppTheme.white,
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
