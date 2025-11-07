import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// İki seçenekli, pill tarzı switch
/// Örnek kullanım:
/// LobiSegmentedSwitch(
///   isFirstSelected: true,
///   firstLabel: 'Yaklaşan',
///   secondLabel: 'Geçmiş',
///   onChanged: (isFirst) { ... },
/// )
class LobiSegmentedSwitch extends StatelessWidget {
  final bool isFirstSelected;
  final String firstLabel;
  final String secondLabel;
  final ValueChanged<bool> onChanged;
  final double? height;

  const LobiSegmentedSwitch({
    super.key,
    required this.isFirstSelected,
    required this.firstLabel,
    required this.secondLabel,
    required this.onChanged,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: height ?? 48.h,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: AppTheme.getSwitchBg(context),
          borderRadius: BorderRadius.circular(999.r),
          border: Border(
            bottom: BorderSide(
              color: AppTheme.getSwitchBorder(context),
              width: 1,
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 🔹 Kayan arka plan (pill)
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment: isFirstSelected
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5, // iki item olduğu için yarısı
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getSwitchActive(context),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                ),

                // 🔹 Üstte tıklanabilir label'lar
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(true),
                        child: Center(
                          child: Text(
                            firstLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isFirstSelected
                                  ? AppTheme.getSwitchText(context)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(false),
                        child: Center(
                          child: Text(
                            secondLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: !isFirstSelected
                                  ? AppTheme.getSwitchText(context)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
