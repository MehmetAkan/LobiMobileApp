import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventsSection extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const EventsSection({
    super.key,
    required this.title,
    this.onSeeAll,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              padding ?? EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h),
          child: _buildHeader(context),
        ),
        SizedBox(height: 10.h),
        child,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasTap = onSeeAll != null;

    final titleRow = Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppTheme.getTextHeadColor(context),
          ),
        ),
        if (hasTap) ...[
          SizedBox(width: 3.w),
          Icon(
            LucideIcons.chevronRight400,
            size: 20.sp,
            color: AppTheme.getTextDescColor(context),
          ),
        ],
      ],
    );

    if (hasTap) {
      return GestureDetector(
        onTap: onSeeAll,
        behavior: HitTestBehavior.opaque,
        child: titleRow,
      );
    }

    return titleRow;
  }
}
