import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfilePhotoModal {
  static void show(
    BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onChoosePhoto,
    required VoidCallback onDeletePhoto,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomModalSheet(
        headerLeft: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppTheme.zinc200,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.zinc300, width: 1.w),
              ),
              child: Icon(
                LucideIcons.camera,
                size: 24.sp,
                color: AppTheme.zinc700,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              'Profil Fotoğrafı',
              style: AppTextStyles.titleHead_XL.copyWith(
                color: AppTheme.getTextHeadColor(context),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Fotoğrafınızı değiştirebilir veya silebilirsiniz.',
              style: AppTextStyles.titleDesc_MD.copyWith(
                color: AppTheme.getTextModalDescColor(context),
              ),
            ),
          ],
        ),
        showDivider: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fotoğraf Çek & Fotoğraf Seç (Grouped)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.zinc200,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppTheme.zinc300),
              ),
              child: Column(
                children: [
                  _buildOption(
                    context,
                    icon: LucideIcons.camera,
                    title: 'Fotoğraf Çek',
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      onTakePhoto();
                    },
                  ),
                  Divider(height: 1, color: AppTheme.zinc300),
                  _buildOption(
                    context,
                    icon: LucideIcons.image400,
                    title: 'Galeriden Seç',
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      onChoosePhoto();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            // Fotoğrafı Sil (Separate - Destructive)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.red50,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppTheme.red100),
              ),
              child: _buildOption(
                context,
                icon: LucideIcons.trash2,
                title: 'Fotoğrafı Sil',
                isDestructive: true,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  onDeletePhoto();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Row(
            children: [
              // Icon
              Icon(
                icon,
                size: 20.sp,
                color: isDestructive ? AppTheme.red700 : AppTheme.zinc700,
              ),
              SizedBox(width: 12.w),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDestructive
                        ? AppTheme.red700
                        : AppTheme.getTextHeadColor(context),
                  ),
                ),
              ),
              // Arrow
              if (!isDestructive)
                Icon(
                  LucideIcons.chevronRight,
                  size: 20.sp,
                  color: AppTheme.zinc400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
