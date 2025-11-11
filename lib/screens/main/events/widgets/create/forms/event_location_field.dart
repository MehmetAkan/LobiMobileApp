import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventLocationField - Etkinlik konum seçimi
/// 
/// Özellikler:
/// - Sol tarafta map pin icon
/// - ReadOnly (modal ile seçilir)
/// - Placeholder
/// - İleride özelleştirme için hazır
/// 
/// Kullanım:
/// ```dart
/// EventLocationField(
///   value: selectedLocation,
///   onTap: () {
///     // Konum modal aç
///   },
/// )
/// ```
class EventLocationField extends StatelessWidget {
  /// Seçili konum metni
  final String? value;

  /// Placeholder
  final String placeholder;

  /// Tıklama callback (modal açmak için)
  final VoidCallback onTap;

  const EventLocationField({
    super.key,
    this.value,
    this.placeholder = 'Konum seçin',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value ?? placeholder;
    final hasValue = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.getEventFieldBg(context),
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Map pin icon
                Icon(
                  Icons.location_on_outlined,
                  size: 22.sp,
                  color: hasValue
                      ? AppTheme.getEventFieldText(context)
                      : AppTheme.getEventFieldPlaceholder(context),
                ),
                SizedBox(width: 12.w),
                // Text
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: hasValue
                          ? AppTheme.getEventFieldText(context)
                          : AppTheme.getEventFieldPlaceholder(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}