import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/utils/event_description_helper.dart';

/// EventDetailDescription - Açıklama içeriği
///
/// Kullanıcının yazdığı açıklama metni
/// Uzun metinler için otomatik wrap
class EventDetailDescription extends StatelessWidget {
  final String description;

  const EventDetailDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    // JSON Quill → Plain text
    final plainText = EventDescriptionHelper.getPlainText(description);

    if (plainText.isEmpty) {
      return Text(
        'Açıklama bulunmuyor.',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.getTextDescColor(context).withOpacity(0.7),
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      plainText,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.white.withValues(alpha: 0.9),
        height: 1.6,
      ),
    );
  }
}
