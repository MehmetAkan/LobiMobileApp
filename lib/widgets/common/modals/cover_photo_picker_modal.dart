import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';

/// CoverPhotoPickerModal - Kapak fotoğrafı seçme modal'ı
///
/// Kullanım:
/// ```dart
/// final result = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const CoverPhotoPickerModal(),
///     fullscreenDialog: true,
///   ),
/// );
/// if (result != null) {
///   setState(() => coverPhotoUrl = result);
/// }
/// ```
class CoverPhotoPickerModal extends StatefulWidget {
  const CoverPhotoPickerModal({super.key});

  @override
  State<CoverPhotoPickerModal> createState() => _CoverPhotoPickerModalState();
}

class _CoverPhotoPickerModalState extends State<CoverPhotoPickerModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CategoryModel> _categories = CategoryModel.getMockCategories();
  int _currentTabIndex = 0; // ✨ Aktif tab index'ini takip et

  // Mock fotoğraflar (geçici)
  final Map<String, List<String>> _mockPhotos = {
    'featured': [
      'https://picsum.photos/seed/f1/400/400',
      'https://picsum.photos/seed/f2/400/400',
      'https://picsum.photos/seed/f3/400/400',
      'https://picsum.photos/seed/f4/400/400',
    ],
    '1': [
      // Konser
      'https://picsum.photos/seed/k1/400/400',
      'https://picsum.photos/seed/k2/400/400',
      'https://picsum.photos/seed/k3/400/400',
      'https://picsum.photos/seed/k4/400/400',
      'https://picsum.photos/seed/k5/400/400',
      'https://picsum.photos/seed/k6/400/400',
    ],
    '2': [
      // Tiyatro
      'https://picsum.photos/seed/t1/400/400',
      'https://picsum.photos/seed/t2/400/400',
      'https://picsum.photos/seed/t3/400/400',
    ],
    // Her kategori için mock data eklenebilir
  };

  @override
  void initState() {
    super.initState();
    // +1 çünkü ilk tab "Önerilen"
    _tabController = TabController(length: _categories.length + 1, vsync: this);

    // ✨ Tab değişikliklerini dinle
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPhotoSelected(String photoUrl) {
    Navigator.of(context).pop(photoUrl);
  }

  void _onPickFromGallery() {
    // TODO: Image Picker entegrasyonu
    debugPrint('Galeriden seç');
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              // Header
              _buildHeader(statusBarHeight),

              // Tab Bar
              _buildTabBar(),

              // Content Area (TabBarView)
              Expanded(child: _buildContent()),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomButton()),
        ],
      ),
    );
  }

  /// Background (blur)
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

  /// Header: [X] Kapak Görseli Ekle [🔍]
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
          // Kapat butonu
          _buildIconButton(
            icon: LucideIcons.x400,
            onTap: () => Navigator.of(context).pop(),
          ),

          // Başlık
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

          // Arama butonu (disabled)
          Opacity(
            opacity: 0.5,
            child: _buildIconButton(
              icon: LucideIcons.search400,
              onTap: null, // Şimdilik disabled
            ),
          ),
        ],
      ),
    );
  }

  /// Icon Button
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

  /// Tab Bar (Icon + Text)
  Widget _buildTabBar() {
    return Container(
      height: 60.h,
      margin: EdgeInsets.only(bottom: 0), // ✨ Alt margin kaldırıldı
      child: TabBar(
        tabAlignment: TabAlignment.start,
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.only(
          left: 20.w,
          right: 10.w,
        ), // ✨ Sol padding 20w olarak ayarlandı
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
        tabs: [
          // İlk tab: Önerilen
          _buildTab(
            icon: LucideIcons.star400,
            label: 'Önerilen',
            isActive: _currentTabIndex == 0,
          ),
          // Kategori tabları
          ..._categories.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final category = entry.value;
            return _buildTab(
              icon: LucideIcons.image400,
              label: category.name,
              isActive: _currentTabIndex == index,
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Tek bir tab
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

  /// Content Area
  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Önerilen tab
        _buildRecommendedTab(),

        // Kategori tabları
        ..._categories.map((category) {
          return _buildCategoryTab(category);
        }).toList(),
      ],
    );
  }

  /// Önerilen Tab (2 sütun grid)
  Widget _buildRecommendedTab() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        0,
        20.w,
        60.h,
      ), // ✨ Üst padding tamamen kaldırıldı
      child: GridView.builder(
        padding: EdgeInsets.only(top: 10.h), // ✨ Grid'in kendi padding'i
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15.w,
          mainAxisSpacing: 15.h,
          childAspectRatio: 1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  /// Kategori Card (Önerilen tab için)
  Widget _buildCategoryCard(CategoryModel category) {
    // Her kategori için featured fotoğrafı al (geçici)
    final photoUrl =
        _mockPhotos[category.id]?.first ??
        'https://picsum.photos/seed/${category.id}/400/400';

    return GestureDetector(
      onTap: () {
        // Kategoriye tıklanınca o kategorinin tab'ına geç
        final index = _categories.indexOf(category) + 1;
        _tabController.animateTo(index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fotoğraf
            Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppTheme.zinc300);
              },
            ),

            // Blur backdrop + Text
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
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
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

  /// Kategori Tab (3 sütun grid)
  Widget _buildCategoryTab(CategoryModel category) {
    final photos = _mockPhotos[category.id] ?? [];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        0,
        20.w,
        100.h,
      ), // ✨ Üst padding tamamen kaldırıldı
      child: GridView.builder(
        padding: EdgeInsets.only(top: 10.h), // ✨ Grid'in kendi padding'i
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return _buildPhotoCard(photos[index]);
        },
      ),
    );
  }

  /// Fotoğraf Card
  Widget _buildPhotoCard(String photoUrl) {
    return GestureDetector(
      onTap: () => _onPhotoSelected(photoUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: AppTheme.zinc300);
          },
        ),
      ),
    );
  }

  /// Bottom Button (Kütüphaneden Seç)
  Widget _buildBottomButton() {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.black800.withOpacity(0),
              AppTheme.black800.withOpacity(0.1),
              AppTheme.black800.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.only(bottom: 30, top: 0, left: 20, right: 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: GestureDetector(
            onTap: _onPickFromGallery,
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.images400,
                      size: 22.sp,
                      color: AppTheme.black800,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Galeriden Seç',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
