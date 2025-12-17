import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AccountDeletionModal {
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _AccountDeletionContent(),
    );
  }
}

class _AccountDeletionContent extends StatefulWidget {
  const _AccountDeletionContent();

  @override
  State<_AccountDeletionContent> createState() =>
      _AccountDeletionContentState();
}

class _AccountDeletionContentState extends State<_AccountDeletionContent> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _isValid = _controller.text.trim() == 'Hesabı Sil');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_isValid) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
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
                      _buildIconCancelButton(
                        context,
                        LucideIcons.triangleAlert400,
                      ),
                      _buildIconButton(
                        context,
                        LucideIcons.x400,
                        onTap: () => Navigator.of(context).pop(false),
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
                        'Hesabı Sil',
                        style: AppTextStyles.titleHead_XL.copyWith(
                          color: AppTheme.getTextHeadColor(context),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '30 gün içinde giriş yapmazsanız, hesabınız ve tüm verileriniz kalıcı olarak silinecektir.',
                        style: AppTextStyles.titleDesc_MD.copyWith(
                          color: AppTheme.getTextDescColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning box
                      Text(
                        'Bu işlem geri alınamaz.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.25,
                          color: AppTheme.getSettingsLogout(context),
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            'Devam etmek için aşağıya',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextDescColor(context),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '"Hesabı Sil"',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextHeadColor(context),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'yazın',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTextDescColor(context),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Text input
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Hesabı Sil',
                          hintStyle: TextStyle(color: AppTheme.zinc400),
                          filled: true,
                          fillColor: AppTheme.zinc200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide(
                              color: _isValid
                                  ? AppTheme.red500
                                  : AppTheme.zinc300,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: _isValid ? _confirm : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.red800,
                                  disabledBackgroundColor: AppTheme.zinc600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                ),
                                child: Text(
                                  'Hesabı Sil',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    letterSpacing: -0.25,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: SizedBox(
                              height: 50.h,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppTheme.black800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                ),
                                child: Text(
                                  'Vazgeç',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    letterSpacing: -0.25,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
              border: Border.all(
                color: AppTheme.getModalIconBorder(context),
                width: 1.w,
              ),
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

  Widget _buildIconCancelButton(
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
              color: AppTheme.getLogoutModalIconBg(context),
              border: Border.all(color: AppTheme.red100, width: 1.w),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                iconData,
                size: 22.sp,
                color: AppTheme.getLogoutModalIconText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
