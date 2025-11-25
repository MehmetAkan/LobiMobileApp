import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_sheet.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventAccessCapacityModal {
  static Future<int?> show({required BuildContext context, int? currentValue}) {
    return showModalBottomSheet<int?>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CapacityContent(currentValue: currentValue),
    );
  }

  static String getDisplayText(int? capacity) {
    return capacity == null ? 'Sınırsız' : '$capacity kişi';
  }
}

class _CapacityContent extends StatefulWidget {
  final int? currentValue;

  const _CapacityContent({this.currentValue});

  @override
  State<_CapacityContent> createState() => _CapacityContentState();
}

class _CapacityContentState extends State<_CapacityContent> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue?.toString() ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Navigator.of(context).pop(null);
      return;
    }

    final value = int.tryParse(text);
    if (value != null && value > 0) {
      Navigator.of(context).pop(value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen geçerli bir sayı girin'),
          backgroundColor: AppTheme.red900,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onRemove() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return EventAccessModalSheet(
      icon: LucideIcons.users400,
      title: 'Maxsimum Kapasite',
      description:
          'Etkinliğe maxsimum kaç kişi katılabilir bu belirleyin. Kapasite dolduğunda kayıtlar otomatik kapanır.',
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppTheme.zinc300),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6), // Max 999,999 kişi
                  ],
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.black800,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    fillColor: AppTheme.red900,
                    hintText: 'Sınırsız',
                    hintStyle: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.zinc600,
                      height: 1.2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  // Kaldır butonu
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onRemove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.red900,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        side: BorderSide(color: AppTheme.zinc300, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.circleX400,
                            size: 18.sp,
                            color: AppTheme.red900,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Kaldır',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Kaydet butonu
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black800,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.white
              : AppTheme.getAppBarButtonBg(context).withOpacity(0.3),
          borderRadius: BorderRadius.circular(25.r),
          border: isPrimary
              ? null
              : Border.all(color: AppTheme.white.withOpacity(0.2), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppTheme.black800 : AppTheme.white,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
