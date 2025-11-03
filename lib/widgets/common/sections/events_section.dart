import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

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
        
        SizedBox(height: 15.h),
        child,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextHeadColor(context),
                  height: 1.1,
                ),
              ),
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
          ),
        ),
        
        // Sağ taraf - Tümünü Gör butonu
        if (showSeeAll && onSeeAll != null)
          _buildSeeAllButton(context),
      ],
    );
  }

  Widget _buildSeeAllButton(BuildContext context) {
    return GestureDetector(
      onTap: onSeeAll,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.getHomeButtonBgColor(context),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppTheme.getHomeButtonBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tümünü Gör',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getHomeButtonTextColor(context),
              ),
            ),
          ],
        ),
      ),
        
    );
  }
}