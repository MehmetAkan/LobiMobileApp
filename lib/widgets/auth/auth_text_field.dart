import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onTap; // date picker gibi özel durumlarda
  final bool readOnly; // doğum tarihi gibi direkt yazdırmak istemiyorsak
  final TextAlign textAlign; // doğrulama kodu ortalı olsun diye
  final int? maxLength; // doğrulama kodu 6 hane gibi

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.onTap,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15);
    final borderColor = AppTheme.getAuthInputBorder(context);
    final focusedBorderColor = AppTheme.getAuthInputBorderFocus(context);
    final fillColor = AppTheme.getAuthInputBg(context);
    final labelColor = AppTheme.getAuthHeadText(context);
    final textColor = AppTheme.getAuthInputText(context);
    final errorColor = AppTheme.red700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLength: maxLength,
          textAlign: textAlign,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: obscureText ? 2 : 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppTheme.getAuthInputHint(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 14,
            ),
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: prefix,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 12, left: 8),
                    child: suffix,
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: focusedBorderColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: errorColor, width: 1),
            ),
            // Flutter TextField default olarak errorText'i InputDecoration içinde bekler
            errorText: errorText,
            errorStyle: TextStyle(
              color: errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
