import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart'; // kendi yoluna göre ayarla

class  AuthVerificationInput extends StatelessWidget {
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
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.black800,
        ),
        decoration: BoxDecoration(
          color: AppTheme.zinc200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.zinc300),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 50,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.black800,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
