import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LogoutModal {
  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    CustomModalSheet.show(
      context: context,
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.red100,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.zinc300, width: 1.w),
            ),
            child: Icon(
              LucideIcons.logOut,
              size: 24.sp,
              color: AppTheme.red800,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Çıkış Yap',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
            style: TextStyle(
              fontSize: 14.sp,
              letterSpacing: -0.25,
              fontWeight: FontWeight.w500,
              color: AppTheme.zinc700,
            ),
          ),
        ],
      ),
      showDivider: true,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red100,
                foregroundColor: AppTheme.red900,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Çıkış Yap',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                side: BorderSide(color: AppTheme.zinc400, width: 1),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                'İptal',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
