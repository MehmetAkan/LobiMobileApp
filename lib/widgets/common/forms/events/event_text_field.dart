import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventTextField - Etkinlik formu için text input
///
/// Özellikler:
/// - Label YOK (sadece placeholder)
/// - Özelleştirilebilir keyboard type
/// - Max length desteği
/// - Suffix icon desteği
///
/// Kullanım:
/// ```dart
/// EventTextField(
///   controller: titleController,
///   placeholder: 'Etkinlik başlığını girin',
///   maxLength: 100,
/// )
/// ```
class EventTextField extends StatelessWidget {
  /// Text controller
  final TextEditingController controller;

  /// Placeholder text
  final String placeholder;

  /// Keyboard tipi
  final TextInputType keyboardType;

  /// Maksimum karakter sayısı
  final int? maxLength;

  /// Maksimum satır sayısı
  final int? maxLines;

  /// Suffix icon (sağ taraf)
  final Widget? suffix;

  /// Prefix icon (sol taraf)
  final Widget? prefix;

  /// TextField yüksekliği
  final double? height;

  /// onChanged callback
  final Function(String)? onChanged;

  /// onTap callback (readonly input'lar için)
  final VoidCallback? onTap;

  /// Readonly mi?
  final bool readOnly;

  const EventTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.maxLines = 1,
    this.suffix,
    this.prefix,
    this.height,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

@override
Widget build(BuildContext context) {
  return Container(
    height: height ?? 50.h,
    decoration: BoxDecoration(
      color: AppTheme.getEventFieldBg(context),
      borderRadius: BorderRadius.circular(35.r),
    ),
    child: Center( // ✨ Container içine Center ekle
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center, // ✨ Bu kalacak
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.getEventFieldText(context),
          height: 1.2,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.getEventFieldPlaceholder(context),
            height: 1.2, // ✨ Placeholder height'ı da text ile aynı
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h, // ✨ 0 yerine 18.h (dengeli padding)
          ),
          counterText: '',
          prefixIcon: prefix != null
              ? Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: prefix,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: EdgeInsets.only(right: 12.w, left: 8.w),
                  child: suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    ),
  );
}
}