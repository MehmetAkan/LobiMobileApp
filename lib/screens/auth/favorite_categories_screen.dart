import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/services/category_service.dart';
import 'package:lobi_application/data/services/favorite_categories_service.dart';
import 'package:lobi_application/screens/main/main_navigation_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/common/categories/selectable_category_chip.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteCategoriesScreen extends StatefulWidget {
  const FavoriteCategoriesScreen({super.key});

  @override
  State<FavoriteCategoriesScreen> createState() =>
      _FavoriteCategoriesScreenState();
}

class _FavoriteCategoriesScreenState extends State<FavoriteCategoriesScreen> {
  final _categoryService = CategoryService();
  final _favoriteCategoriesService = FavoriteCategoriesService();

  List<CategoryModel> _categories = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Kategoriler yüklenemedi: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        getIt<AppFeedbackService>().showError('Kategoriler yüklenemedi');
      }
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedIds.contains(categoryId)) {
        _selectedIds.remove(categoryId);
      } else {
        _selectedIds.add(categoryId);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedIds.length < 3) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _favoriteCategoriesService.saveFavoriteCategories(
        userId: userId,
        categoryIds: _selectedIds.toList(),
      );

      if (!mounted) return;

      // Navigate to home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('⚠️ Kaydetme hatası: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        getIt<AppFeedbackService>().showError('Kaydetme başarısız');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isButtonEnabled = _selectedIds.length >= 3 && !_isSaving;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
                        child: const AuthBackButton(),
                      ),
                      Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: AppTheme.getAuthIconBg(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.heart400,
                            size: 30.sp,
                            color: AppTheme.getAuthIconColor(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'İlgi Alanlarını Seç',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 35.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getAuthHeadText(context),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Sana uygun etkinlikleri önerelim. En az 3 kategori seç.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getAuthDescText(context),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Counter
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIds.length >= 3
                              ? AppTheme.green500.withValues(alpha: 0.1)
                              : AppTheme.getAuthCardBg(context),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedIds.length >= 3
                                  ? LucideIcons.circleCheck400
                                  : LucideIcons.info400,
                              size: 16.sp,
                              color: _selectedIds.length >= 3
                                  ? AppTheme.green500
                                  : AppTheme.getAuthCarText(context),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Seçilen: ${_selectedIds.length}/3',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _selectedIds.length >= 3
                                    ? AppTheme.green500
                                    : AppTheme.getAuthCarText(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25.h),

                      // Categories
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.h),
                            child: CircularProgressIndicator(
                              color: AppTheme.zinc800,
                            ),
                          ),
                        )
                      else
                        _buildCategoriesGrid(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h + bottomInset),
                child: AuthPrimaryButton(
                  label: _isSaving ? 'Kaydediliyor...' : 'Devam Et',
                  onTap: isButtonEnabled ? _handleContinue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Wrap(
      spacing: 5.w,
      runSpacing: 5.h,
      children: _categories.map((category) {
        return SelectableCategoryChip(
          category: category,
          isSelected: _selectedIds.contains(category.id),
          onTap: () => _toggleCategory(category.id),
        );
      }).toList(),
    );
  }
}
