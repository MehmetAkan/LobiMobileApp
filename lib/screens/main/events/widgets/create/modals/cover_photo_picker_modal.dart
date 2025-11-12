import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/models/event_image_model.dart';
import 'package:lobi_application/data/services/image_picker_service.dart';
import 'package:lobi_application/providers/event_image_provider.dart';
import 'package:lobi_application/providers/category_provider.dart';
import 'package:lobi_application/utils/image_picker_helper.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';

/// CoverPhotoPickerModal - Kapak fotoğrafı seçme modal'ı
///
/// ✨ FINAL: Direkt galeri açma + crop özelliği
class CoverPhotoPickerModal extends ConsumerStatefulWidget {
  const CoverPhotoPickerModal({super.key});

  @override
  ConsumerState<CoverPhotoPickerModal> createState() =>
      _CoverPhotoPickerModalState();
}

class _CoverPhotoPickerModalState extends ConsumerState<CoverPhotoPickerModal>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onPhotoSelected(String photoUrl) {
    Navigator.of(context).pop(photoUrl);
  }

  /// ✨ GÜNCEL - Direkt galeri aç ve kırp
  Future<void> _onPickFromGallery() async {
    setState(() => _isPickingImage = true);

    try {
      final pickerHelper = ImagePickerHelper(getIt<ImagePickerService>());
      final result = await pickerHelper.pickAndCropImage();

      if (!mounted) return;

      if (result.isSuccess && result.imageFile != null) {
        // Başarılı - kırpılmış resmi döndür
        Navigator.of(context).pop(result.imageFile?.path);
      } else if (result.errorMessage != null) {
        // Hata mesajı göster
        _showErrorSnackBar(result.errorMessage!);
      }
      // Cancelled durumunda hiçbir şey yapma
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _navigateToCategory(
    CategoryModel category,
    List<CategoryModel> allCategories,
  ) {
    final categoryIndex = allCategories.indexOf(category);
    if (categoryIndex != -1) {
      _tabController?.animateTo(categoryIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final categoriesAsync = ref.watch(allCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (_tabController == null) {
          _tabController = TabController(
            length: categories.length + 1,
            vsync: this,
          );

          _tabController!.addListener(() {
            if (_tabController!.indexIsChanging) {
              setState(() {
                _currentTabIndex = _tabController!.index;
              });
            }
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              _buildBackground(),
              Column(
                children: [
                  _buildHeader(statusBarHeight),
                  _buildTabBar(categories),
                  Expanded(child: _buildContent(categories)),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomButton(),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(body: _buildFullScreenLoading()),
      error: (error, stack) =>
          Scaffold(body: _buildFullScreenError(error.toString())),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4,
              child: Image.asset(
                'assets/images/system/event-example-white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: AppTheme.getCreateEventBg(context).withOpacity(0.30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 10.h,
        left: 20.w,
        right: 20.w,
        bottom: 15.h,
      ),
      child: Row(
        children: [
          _buildIconButton(
            icon: LucideIcons.x400,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Kapak Görseli Ekle',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.5,
            child: _buildIconButton(icon: LucideIcons.search400, onTap: null),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      width: 45.w,
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getAppBarButtonBg(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getAppBarButtonBorder(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 25.sp,
                color: AppTheme.getAppBarButtonColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(List<CategoryModel> categories) {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(bottom: 0),
      child: TabBar(
        tabAlignment: TabAlignment.start,
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.only(left: 20.w, right: 10.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
        tabs: [
          _buildTab(
            icon: LucideIcons.star400,
            label: 'Önerilen',
            isActive: _currentTabIndex == 0,
          ),
          ...categories.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final category = entry.value;
            return _buildTab(
              icon: category.iconData,
              label: category.name,
              isActive: _currentTabIndex == index,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: isActive ? AppTheme.white : AppTheme.white.withOpacity(0.5),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppTheme.white
                  : AppTheme.white.withOpacity(0.5),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<CategoryModel> categories) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRecommendedTab(categories),
        ...categories.map((category) {
          return _buildCategoryTab(category);
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendedTab(List<CategoryModel> categories) {
    final featuredImagesAsync = ref.watch(featuredEventImagesProvider);

    return featuredImagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return _buildEmptyState('Henüz önerilen resim yok');
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 60.h),
          child: GridView.builder(
            padding: EdgeInsets.only(top: 10.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 15.h,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              final category = categories.firstWhere(
                (cat) => cat.id == image.categoryId,
                orElse: () => categories.first,
              );
              return _buildFeaturedImageCard(image, category, categories);
            },
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildFeaturedImageCard(
    EventImageModel image,
    CategoryModel category,
    List<CategoryModel> allCategories,
  ) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category, allCategories),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.zinc300,
                  child: Icon(LucideIcons.image400, color: AppTheme.zinc500),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.black800.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(CategoryModel category) {
    final categoryImagesAsync = ref.watch(
      eventImagesByCategoryProvider(category.id),
    );

    return categoryImagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return _buildEmptyState('Bu kategoride henüz resim yok');
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 60.h),
          child: GridView.builder(
            padding: EdgeInsets.only(top: 10.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return _buildImageTile(image);
            },
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildImageTile(EventImageModel image) {
    return GestureDetector(
      onTap: () => _onPhotoSelected(image.url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          image.url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.zinc300,
              child: Icon(
                LucideIcons.image400,
                color: AppTheme.zinc500,
                size: 20.sp,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFullScreenLoading() {
    return Stack(
      children: [
        _buildBackground(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.white),
              SizedBox(height: 16.h),
              Text(
                'Kategoriler yükleniyor...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppTheme.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenError(String error) {
    return Stack(
      children: [
        _buildBackground(),
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.badge400, color: AppTheme.white, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  'Kategoriler yüklenemedi',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: AppTheme.white));
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.badge400, color: AppTheme.white, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Resimler yüklenemedi',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16.sp,
          color: AppTheme.white.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.getCreateEventBg(context).withOpacity(0),
            AppTheme.getCreateEventBg(context).withOpacity(0.9),
            AppTheme.getCreateEventBg(context),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: _isPickingImage ? null : _onPickFromGallery,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.black800,
            disabledBackgroundColor: AppTheme.white.withOpacity(0.5),
            disabledForegroundColor: AppTheme.black800.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          icon: _isPickingImage
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      AppTheme.black800.withOpacity(0.5),
                    ),
                  ),
                )
              : Icon(LucideIcons.upload400, size: 20.sp),
          label: Text(
            _isPickingImage ? 'Yükleniyor...' : 'Galeriden Seç',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

 
}
