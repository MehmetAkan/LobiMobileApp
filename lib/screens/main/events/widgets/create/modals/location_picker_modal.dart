import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/services/places_service.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/providers/location_provider.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import 'dart:async'; // ✨ YENİ - Timer için

/// LocationPickerModal - Konum seçimi modal'ı
///
/// Kullanım:
/// ```dart
/// final location = await LocationPickerModal.show(context: context);
/// if (location != null) {
///   setState(() => selectedLocation = location);
/// }
/// ```
class LocationPickerModal {
  static Future<LocationModel?> show({required BuildContext context}) {
    return showModalBottomSheet<LocationModel>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => const _LocationPickerContent(),
    );
  }
}

class _LocationPickerContent extends ConsumerStatefulWidget {
  const _LocationPickerContent();

  @override
  ConsumerState<_LocationPickerContent> createState() =>
      _LocationPickerContentState();
}

class _LocationPickerContentState
    extends ConsumerState<_LocationPickerContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer; // ✨ YENİ - Debounce timer

  @override
  void initState() {
    super.initState();

    // ✨ YENİ - Otomatik arama (debounce ile)
    _searchController.addListener(() {
      final query = _searchController.text.trim();

      // UI'ı güncelle (temizle butonu için)
      setState(() {});

      // Önceki timer'ı iptal et
      _debounceTimer?.cancel();

      if (query.isEmpty) {
        ref.read(placeSearchProvider.notifier).clearResults();
      } else if (query.length >= 2) {
        // 500ms bekle, sonra ara
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          ref.read(placeSearchProvider.notifier).searchPlaces(query: query);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // ✨ YENİ - Timer'ı temizle
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onPlaceSelected(String placeId) async {
    // Detayları al
    final notifier = ref.read(placeSearchProvider.notifier);
    final location = await notifier.selectPlace(placeId);

    if (location != null && mounted) {
      // Modal'ı kapat ve sonucu döndür
      Navigator.of(context).pop(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.zinc1000,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          // Handle
          _buildHandle(),

          // Header
          _buildHeader(),

          // Search field
          _buildSearchField(),

          SizedBox(height: 10.h),

          // Results
          Expanded(child: _buildResults()),

          // Klavye padding
          SizedBox(height: keyboardHeight),
        ],
      ),
    );
  }

  /// Handle (drag indicator)
  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppTheme.getCreateEventBg(context).withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Konum Seç',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.getEventFieldText(context),
                height: 1.2,
              ),
            ),
          ),
          // Kapat butonu
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 45.w,
              height: 45.w,
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
                  LucideIcons.x400,
                  size: 18.sp,
                  color: AppTheme.getAppBarButtonColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Field
  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.black800,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(
              Icons.search,
              size: 22.sp,
              color: AppTheme.getEventFieldPlaceholder(context),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true, // ✨ YENİ - Otomatik focus
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.getEventFieldText(context),
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Konum ara...',
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getEventFieldPlaceholder(context),
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),

            // ✨ YENİ - Temizle butonu (yazı varsa göster)
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(placeSearchProvider.notifier).clearResults();
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  margin: EdgeInsets.only(right: 5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.getEventFieldPlaceholder(
                      context,
                    ).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: AppTheme.getEventFieldText(context),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Results
  Widget _buildResults() {
    final searchState = ref.watch(placeSearchProvider);

    return searchState.when(
      data: (predictions) {
        if (predictions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 48.sp,
                  color: AppTheme.getEventFieldPlaceholder(
                    context,
                  ).withOpacity(0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Aramak için en az 2 karakter girin',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getEventFieldPlaceholder(context),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          itemCount: predictions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1.h,
            color: AppTheme.getEventFieldPlaceholder(context).withOpacity(0.1),
          ),
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return _buildLocationItem(prediction);
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.black800),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppTheme.red700),
              SizedBox(height: 16.h),
              Text(
                'Bir hata oluştu',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getEventFieldText(context),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.getEventFieldPlaceholder(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Location Item
  Widget _buildLocationItem(PlacePrediction prediction) {
    return InkWell(
      onTap: () => _onPlaceSelected(prediction.placeId),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.getEventFieldBg(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20.sp,
                  color: AppTheme.zinc800,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.mainText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getEventFieldText(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    prediction.secondaryText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.getEventFieldPlaceholder(context),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppTheme.getEventFieldPlaceholder(context),
            ),
          ],
        ),
      ),
    );
  }
}
