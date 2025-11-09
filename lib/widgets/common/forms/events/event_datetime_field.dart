import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';

/// EventDateTimeField - Etkinlik için tarih + saat seçici
/// 
/// Özellikler:
/// - Tarih + Saat tek picker'da
/// - iOS tarzı bottom sheet
/// - Placeholder desteği
/// - Format: "5 Kas - 14:00"
/// 
/// Kullanım:
/// ```dart
/// EventDateTimeField(
///   value: startDate,
///   placeholder: 'Başlangıç',
///   onChanged: (date) => setState(() => startDate = date),
/// )
/// ```
class EventDateTimeField extends StatelessWidget {
  /// Seçili tarih
  final DateTime? value;

  /// Placeholder text
  final String placeholder;

  /// onChanged callback
  final Function(DateTime) onChanged;

  /// Minimum tarih (null ise şimdi)
  final DateTime? firstDate;

  /// Maksimum tarih (null ise 5 yıl sonrası)
  final DateTime? lastDate;

  const EventDateTimeField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  /// Tarih + saat picker'ı aç
  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    
    // ✨ Min ve max tarih hesapla
    final minDate = firstDate ?? now;
    final maxDate = lastDate ?? now.add(const Duration(days: 1825));
    
    // ✨ Initial date'i min-max arasında clamp et
    DateTime tempPicked = value ?? now;
    if (tempPicked.isBefore(minDate)) {
      tempPicked = minDate;
    } else if (tempPicked.isAfter(maxDate)) {
      tempPicked = maxDate;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getSwitchBg(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 36,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getTextDescColor(context),
                        ),
                      ),
                    ),
                    Text(
                      placeholder,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onChanged(tempPicked);
                      },
                      child: Text(
                        'Bitti',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.purple900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Picker
                SizedBox(
                  height: 200.h,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: tempPicked, // ✨ Clamp edilmiş tarih
                    minimumDate: minDate,
                    maximumDate: maxDate,
                    use24hFormat: true,
                    onDateTimeChanged: (date) {
                      tempPicked = date;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format: "5 Kas - 14:00"
    final displayText = value != null
        ? value!.toShortDateTime()
        : placeholder;

    return GestureDetector(
      onTap: () => _openPicker(context),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: value != null
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