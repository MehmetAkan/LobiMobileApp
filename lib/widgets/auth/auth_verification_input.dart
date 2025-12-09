import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart'; // kendi yoluna göre ayarla

class AuthVerificationInput extends StatelessWidget {
  const AuthVerificationInput({super.key, required this.onCompleted});

  final void Function(String code) onCompleted;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 6,
      keyboardType: TextInputType.number,
      showCursor: true,
      onCompleted: onCompleted,
      defaultPinTheme: PinTheme(
        width: 50,
        height: 56,
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.getAuthHeadText(context),
        ),
        decoration: BoxDecoration(
          color: AppTheme.getAuthInputBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getAuthInputBorder(context)),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 50,
        height: 56,
        textStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.getAuthHeadText(context),
        ),
        decoration: BoxDecoration(
          color: AppTheme.getAuthInputBorderFocus(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.purple900, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purple900.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}
