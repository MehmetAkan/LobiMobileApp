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
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: _getTextColor(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.green:
        return AppTheme.green900;
      case BadgeType.red:
        return AppTheme.red800;
      case BadgeType.orange:
        return AppTheme.orange900;
      case BadgeType.purple:
        return AppTheme.purple900;
      case BadgeType.black:
        return AppTheme.zinc900;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.green:
        return AppTheme.white;
      case BadgeType.red:
        return AppTheme.white;
      case BadgeType.orange:
        return AppTheme.white;
      case BadgeType.purple:
        return AppTheme.white;
      case BadgeType.black:
        return AppTheme.white;
    }
  }
}
