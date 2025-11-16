import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventModalSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;
  

  const EventModalSheet({
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
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.10),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
            ),
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
                              color: AppTheme.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.white.withOpacity(0.7),
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
                          color: AppTheme.getEventFieldBg(context),
                          borderRadius: BorderRadius.circular(25.r),
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
              color: AppTheme.getAppBarButtonBg(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 22.sp,
                color: AppTheme.getEventFieldPlaceholder(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// EventModalOption - Modal içinde kullanılan seçenek item'ı
class EventModalOption extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool showDivider;

  const EventModalOption({
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
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.white
                          : AppTheme.getEventFieldPlaceholder(context)
                              .withOpacity(0.3),
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            LucideIcons.check600,
                            size: 16.sp,
                            color: AppTheme.black800,
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
                              ? AppTheme.white
                              : AppTheme.white.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.white.withOpacity(0.7),
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
              color: AppTheme.white.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}
