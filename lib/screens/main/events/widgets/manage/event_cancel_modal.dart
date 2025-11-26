import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventCancelModal {
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _EventCancelContent(),
    );
  }
}

class _EventCancelContent extends StatefulWidget {
  const _EventCancelContent();

  @override
  State<_EventCancelContent> createState() => _EventCancelContentState();
}

class _EventCancelContentState extends State<_EventCancelContent> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _isValid = _controller.text.trim() == 'İptal');
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
    return CustomModalSheet(
      headerLeft: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.red100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.triangleAlert,
              color: AppTheme.red900,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Etkinliği İptal Et',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Bu işlem geri alınamaz',
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.zinc700),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning message
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.zinc200,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.zinc300),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info400, color: AppTheme.red900, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Etkinlik iptal edildiğinde tüm katılımcılara bildirim gönderilecek ve etkinlik keşfet sayfasından kaldırılacaktır.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.red900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Confirmation text
          Text(
            'Devam etmek için aşağıya "İptal" yazın',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.black800,
            ),
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
              hintText: 'İptal',
              hintStyle: TextStyle(color: AppTheme.zinc100),
              filled: true,
              fillColor: AppTheme.zinc200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: _isValid ? AppTheme.red500 : AppTheme.zinc300,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ],
      ),
      footer: Row(
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
                  'Etkinliği İptal Et',
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
    );
  }
}
