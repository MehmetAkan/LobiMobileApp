import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
class EventsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showSeeAll;

  const EventsSection({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    required this.child,
    this.padding,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
          child: _buildHeader(context),
        ),
        SizedBox(height: 20.h),
        child,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasTap = showSeeAll && onSeeAll != null;

    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextHeadColor(context),
            height: 1.1,
          ),
        ),
        if (hasTap) ...[
          SizedBox(width: 4.w),
          Icon(
           LucideIcons.chevronRight400,
            size: 20.sp,
            color: AppTheme.getTextHeadColor(context),
          ),
        ],
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow,
        if (subtitle != null) ...[
          SizedBox(height: 1.h),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextDescColor(context),
            ),
          ),
        ],
      ],
    );

    if (hasTap) {
      return GestureDetector(
        onTap: onSeeAll,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
