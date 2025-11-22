import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SelectableCategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.white.withValues(alpha: 1)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppTheme.green1000 : AppTheme.zinc300,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(category.svgPath, width: 20.w, height: 20.h),
            SizedBox(width: 6.w),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14.sp,
                letterSpacing: -0.20,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.green1000 : AppTheme.zinc800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
