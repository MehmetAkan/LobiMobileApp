import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lobi_application/theme/app_theme.dart';

enum BadgeType { green, red, orange, purple, black }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.green:
        return AppTheme.green100;
      case BadgeType.red:
        return AppTheme.red100;
      case BadgeType.orange:
        return AppTheme.orange100;
      case BadgeType.purple:
        return AppTheme.purple100;
      case BadgeType.black:
        return AppTheme.zinc200;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.green:
        return AppTheme.green500;
      case BadgeType.red:
        return AppTheme.red600;
      case BadgeType.orange:
        return AppTheme.orange600;
      case BadgeType.purple:
        return AppTheme.purple900;
      case BadgeType.black:
        return AppTheme.zinc800;
    }
  }
}
