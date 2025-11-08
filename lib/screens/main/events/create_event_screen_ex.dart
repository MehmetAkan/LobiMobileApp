import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// CreateEventScreen - Yeni etkinlik oluşturma sayfası
/// 
/// Özellikler:
/// - FullPageAppBar ile açılır (MaterialPageRoute + fullscreenDialog)
/// - Scroll'da başlık gözükür
/// - Sağda "Kaydet" butonu
class CreateEventScreenEx extends StatefulWidget {
  const CreateEventScreenEx({super.key});

  @override
  State<CreateEventScreenEx> createState() => _CreateEventScreenExState();
}

class _CreateEventScreenExState extends State<CreateEventScreenEx> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSave() {
    // TODO: Form validation ve kaydetme işlemi
    debugPrint('Etkinlik kaydediliyor...');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.h + statusBarHeight;

    return Scaffold(
      body: Stack(
        children: [
          // İçerik
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(20.w, appBarHeight + 20.h, 20.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Büyük başlık (scroll'da kaybolur)
                Text(
                  'Yeni Etkinlik',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextHeadColor(context),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Etkinlik detaylarını girerek yeni bir etkinlik oluştur',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextDescColor(context),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 30.h),
                ...List.generate(20, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppTheme.zinc200,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppTheme.zinc300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Form Field ${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.zinc600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FullPageAppBar(
              title: 'Yeni Etkinlik',
              scrollController: _scrollController,
              style: AppBarStyle.secondary, // veya secondary
              actions: [
                _buildSaveButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kaydet butonu (sağ üst)
  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _onSave,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getNavbarBtnBg(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getNavbarBtnBorder(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.check400,
                  size: 22.sp,
                  color: AppTheme.getButtonIconColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// KULLANIM ÖRNEĞİ - EventsScreen'den açmak
// ============================================

class ExampleUsage {
  static void openCreateEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreenEx(),
        fullscreenDialog: true, // ✨ iOS modal görünümü
      ),
    );
  }
}