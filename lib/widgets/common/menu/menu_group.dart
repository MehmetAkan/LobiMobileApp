import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Reusable menu group widget from EventManageScreen
class MenuGroup extends StatelessWidget {
  final List<MenuItem> items;

  const MenuGroup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.getSettingsCardBorder(context)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _buildMenuItemWidget(context, item),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: 56.w),
                  child: Divider(
                    height: 1,
                    color: AppTheme.getSettingsCardDivider(context),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItemWidget(BuildContext context, MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
          child: Row(
            children: [
              // Icon (SVG or IconData)
              if (item.iconPath != null)
                SvgPicture.asset(item.iconPath!, width: 32.sp, height: 32.sp)
              else if (item.icon != null)
                Icon(
                  item.icon,
                  size: 22.sp,
                  color: item.isDestructive
                      ? AppTheme.getSettingsLogout(context)
                      : AppTheme.getSettingsCardIcon(context),
                ),

              SizedBox(width: 15.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: -0.20,
                        color: item.isDestructive
                            ? AppTheme.getSettingsLogout(context)
                            : AppTheme.getSettingsCardText(context),
                      ),
                    ),
                    if (item.description != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.zinc600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 20.sp,
                color: AppTheme.getSettingsCardArrowIcon(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String? iconPath; // SVG path
  final IconData? icon; // IconData
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool isDestructive;

  MenuItem({
    this.iconPath,
    this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.isDestructive = false,
  }) : assert(
         iconPath != null || icon != null,
         'Either iconPath or icon must be provided',
       );
}
