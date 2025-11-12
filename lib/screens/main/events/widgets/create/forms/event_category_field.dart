import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventCategoryField - Kategori seçimi için tıklanabilir alan
///
/// `EventLocationField` ve `EventDescriptionField` ile aynı yapıdadır.
class EventCategoryField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;

  const EventCategoryField({
    super.key,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.getEventFieldBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.getEventFieldBorder(context),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.layoutGrid400, // Kategori iconu
              size: 20.sp,
              color: hasValue
                  ? AppTheme.white
                  : AppTheme.getEventFieldPlaceholder(context),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasValue ? value! : 'Kategori Seç', // Placeholder
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: hasValue
                      ? AppTheme.white
                      : AppTheme.getEventFieldPlaceholder(context),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}