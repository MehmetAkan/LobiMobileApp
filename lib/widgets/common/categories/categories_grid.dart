import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/theme/app_theme.dart';

class CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CategoriesGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final int midPoint = (categories.length / 2).ceil();
    final firstRow = categories.sublist(0, midPoint);
    final secondRow = categories.sublist(midPoint);

    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: firstRow.map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: _CategoryChip(
                    category: category,
                    onTap: onCategoryTap != null
                        ? () => onCategoryTap!(category)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 5.h),
            Row(
              children: secondRow.map((category) {
                return Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: _CategoryChip(
                    category: category,
                    onTap: onCategoryTap != null
                        ? () => onCategoryTap!(category)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const _CategoryChip({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.getCategoryCardBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.getCategoryCardBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(category.svgPath, width: 22.w, height: 22.h),
            SizedBox(width: 6.w),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextHeadColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
