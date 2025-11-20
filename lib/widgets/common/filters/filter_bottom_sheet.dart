import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/filters/filter_option.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Genel kullanılabilir filter bottom sheet widget'ı
/// Herhangi bir sayfada filter seçenekleri göstermek için kullanılabilir
class FilterBottomSheet extends StatelessWidget {
  final List<FilterOption> options;
  final FilterOption selectedOption;
  final Function(FilterOption) onOptionSelected;

  const FilterBottomSheet({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  static void show({
    required BuildContext context,
    required List<FilterOption> options,
    required FilterOption selectedOption,
    required Function(FilterOption) onOptionSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        options: options,
        selectedOption: selectedOption,
        onOptionSelected: onOptionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 5.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSwitchBg(context),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.r),
            topLeft: Radius.circular(30.r),
            bottomLeft: Radius.circular(45.r),
            bottomRight: Radius.circular(45.r),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (Title + Close Button)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered Title
                    Text(
                      'Filtrele',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),

                    // Close Button (Right)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppTheme.getModalButtonBg(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.x,
                            size: 20.sp,
                            color: AppTheme.getModalButtonText(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (context, index) => Divider(
                  height: 2.h,
                  thickness: 1.h,
                  color: AppTheme.getSwitchActive(context),
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.id == selectedOption.id;

                  return _FilterOptionTile(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      onOptionSelected(option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter seçeneği için tek bir satır
class _FilterOptionTile extends StatelessWidget {
  final FilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppTheme.getFilterActiveText(context);
    final unselectedColor = AppTheme.getFilterText(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            // Icon
            Icon(
              option.icon,
              size: 22.r,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ),

            // Border indicator (sadece "Tüm Etkinlikler" için)
            // if (option.id == 'all')
            //   Container(
            //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            //     decoration: BoxDecoration(
            //       border: Border.all(
            //         color: isSelected ? selectedColor : unselectedColor.withOpacity(0.3),
            //         width: 1.5,
            //       ),
            //       borderRadius: BorderRadius.circular(6.r),
            //     ),
            //     child: Text(
            //       'Varsayılan',
            //       style: TextStyle(
            //         fontSize: 11.sp,
            //         fontWeight: FontWeight.w600,
            //         color: isSelected ? selectedColor : unselectedColor,
            //       ),
            //     ),
            //   ),

            // Check indicator (seçili ise)
            if (isSelected && option.id != 'all')
              Icon(Icons.check, size: 22.r, color: selectedColor),
          ],
        ),
      ),
    );
  }
}
