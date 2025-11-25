import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/providers/category_provider.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventCategoryModal - Kategori seçimi
///
/// Kullanım:
/// ```dart
/// final result = await EventCategoryModal.show(
///   context: context,
///   currentValue: _selectedCategory,
/// );
/// if (result != null) {
///   setState(() => _selectedCategory = result);
/// }
/// ```
class EventCategoryModal {
  static Future<CategoryModel?> show({
    required BuildContext context,
    CategoryModel? currentValue,
  }) {
    return showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => _CategoryContent(currentValue: currentValue),
    );
  }

  /// Display text (Kategori seçildiğinde field'da göstermek için)
  static String getDisplayText(CategoryModel category) {
    return category.name;
  }
}

/// Modal'ın ana içeriğini yöneten stateful widget
class _CategoryContent extends ConsumerStatefulWidget {
  final CategoryModel? currentValue;

  const _CategoryContent({this.currentValue});

  @override
  ConsumerState<_CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends ConsumerState<_CategoryContent> {
  CategoryModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  /// Bir kategori seçildiğinde çalışır
  void _onSelect(CategoryModel value) {
    setState(() => _selected = value);
    // Kısa bir gecikmeyle modal'ı kapatıp değeri döndür
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.of(context).pop(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tüm kategorileri Riverpod'dan izle
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return EventModalSheet(
      icon: LucideIcons.layoutGrid400,
      title: 'Etkinlik Kategorisi',
      description: 'Etkinliğiniz için en uygun kategoriyi seçin.',
      // Riverpod'un async durumunu modal'ın içeriğinde yönetiyoruz
      children: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return [_buildStateMessage('Kategori bulunamadı.')];
          }
          // Kategorileri özel _CategoryOption listesine dönüştür
          return categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _CategoryOption(
              category: category,
              isSelected: _selected == category,
              onTap: () => _onSelect(category),
              showDivider: index != categories.length - 1, // Son item değilse
            );
          }).toList();
        },
        loading: () => [_buildLoadingState()],
        error: (error, stack) => [
          _buildStateMessage('Hata: ${error.toString()}'),
        ],
      ),
    );
  }

  /// Yüklenme durumunu gösteren widget
  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.white.withOpacity(0.7),
        ),
      ),
    );
  }

  /// Hata veya boş liste mesajını gösteren widget
  Widget _buildStateMessage(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.white.withOpacity(0.7),
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// ✨ YENİ: Kategori seçeneği için özel tasarım
/// [Icon] - [Kategori İsmi] - [Check/Circle]
class _CategoryOption extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const _CategoryOption({
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Icon
                Icon(
                  category.iconData, // Modelden gelen dinamik icon
                  size: 22.sp,
                  color: isSelected
                      ? AppTheme.white
                      : AppTheme.white.withOpacity(0.7),
                ),
                SizedBox(width: 12.w),

                // 2. Kategori İsmi
                Expanded(
                  child: Text(
                    category.name, // Modelden gelen isim
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.white
                          : AppTheme.white.withOpacity(0.9),
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // 3. Check icon
                Container(
                  width: 24.sp,
                  height: 24.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.white
                          : AppTheme.getEventFieldPlaceholder(
                              context,
                            ).withOpacity(0.3),
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            LucideIcons.check600,
                            size: 16.sp,
                            color: AppTheme.black800,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: 15.w + 22.sp + 12.w,
            ), // İcona göre hizalı
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.white.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}
