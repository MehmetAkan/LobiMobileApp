import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A reusable modal sheet with a floating design, customizable header, and footer.
class CustomModalSheet extends StatelessWidget {
  final Widget? headerLeft;
  final Widget? headerRight;
  final Widget child;
  final Widget? footer;

  final bool showDivider;

  const CustomModalSheet({
    super.key,
    this.headerLeft,
    this.headerRight,
    required this.child,
    this.footer,
    this.showDivider = false,
  });

  static void show({
    required BuildContext context,
    Widget? headerLeft,
    Widget? headerRight,
    required Widget child,
    Widget? footer,
    bool showDivider = false,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // Display above bottom navbar
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomModalSheet(
        headerLeft: headerLeft,
        headerRight: headerRight,
        footer: footer,
        showDivider: showDivider,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        bottom: 5.h + viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6, // Max 60% of screen height
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.getSwitchBg(context),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Left (Title/Description)
                      if (headerLeft != null) Expanded(child: headerLeft!),

                      // Header Right (Profile/Icon) + Close Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (headerRight != null) ...[
                            headerRight!,
                            SizedBox(width: 10.w),
                          ],
                          // Close Button
                          GestureDetector(
                            onTap: () => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppTheme.getModalButtonBg(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.x400,
                                size: 20.sp,
                                color: AppTheme.getModalButtonText(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 0.h),

                if (showDivider) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.zinc200, // Or appropriate divider color
                  ),
                  SizedBox(height: 20.h),
                ],

                // Body
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 5.h,
                      ),
                      child: child,
                    ),
                  ),
                ),

                // Footer
                if (footer != null) ...[
                  SizedBox(height: 0.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: footer!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
