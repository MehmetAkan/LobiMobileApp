import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventAccessModalSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;

  const EventAccessModalSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Klavye yüksekliği
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        bottom: 5.h + viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getModalBg(context),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.r),
            topLeft: Radius.circular(30.r),
            bottomLeft: Radius.circular(45.r),
            bottomRight: Radius.circular(45.r),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            // Klavye açılınca içerik kayabilsin
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 15.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(context, icon, onTap: null),
                      _buildIconButton(
                        context,
                        LucideIcons.x400,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Title + Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextHeadColor(context),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextDescColor(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.getSettingsCardBg(context),
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: AppTheme.getSettingsCardBorder(context),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData iconData, {
    VoidCallback? onTap,
  }) {
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
              color: AppTheme.getModalIconBg(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 22.sp,
                color: AppTheme.getModalIconText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventModalAccessOption extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool showDivider;

  const EventModalAccessOption({
    super.key,
    required this.isSelected,
    required this.title,
    required this.description,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Check icon
                Container(
                  width: 24.sp,
                  height: 24.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.getSettingsCheckSelectedBg(context)
                        : AppTheme.getSettingsCheckBg(context),
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            LucideIcons.check600,
                            size: 16.sp,
                            color: AppTheme.getSettingsCheckSelectedIcon(
                              context,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.getTextHeadColor(context)
                              : AppTheme.getTextHeadColor(context),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextDescColor(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 20.w + 24.sp + 12.w),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.getSettingsCardDivider(context),
            ),
          ),
      ],
    );
  }
}
