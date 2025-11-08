import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'dart:ui';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.h + statusBarHeight;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        height: screenHeight, // ✨ Tam yükseklik
        child: Stack(
          children: [
            // ✨ Background Image + Blur
            _buildBackground(),

            // ✨ Scrollable Content
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                20.w,
                appBarHeight + 20.h,
                20.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverImage(),
                  SizedBox(height: 20.h),
                  ...List.generate(
                    10,
                    (i) => Container(
                      height: 60.h,
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✨ AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FullPageAppBar(
                title: 'Yeni Etkinlik',
                scrollController: _scrollController,
                style: AppBarStyle.dark,
                actions: [_buildSaveButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Background image + blur overlay
  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4, // 1.0 = normal boyut, 1.2 = %20 büyütülmüş
              child: Image.asset(
                'assets/images/system/event-example-white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Image.asset(
          //   'assets/images/system/event-example-white.png',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          // Blur overlay
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

  /// Kapak fotoğrafı + galeri butonu
  Widget _buildCoverImage() {
    return Stack(
      children: [
        // Cover image - KARE (1:1)
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AspectRatio(
            aspectRatio: 1, // ✨ KARE
            child: Image.asset(
              'assets/images/system/event-example-white.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Galeri butonu (sağ alt)
        Positioned(right: 12.w, bottom: 12.h, child: _buildGalleryButton()),
      ],
    );
  }

  /// Galeri butonu
  Widget _buildGalleryButton() {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        color: AppTheme.getAppBarButtonBg(context),
        border: Border.all(
          color: AppTheme.getAppBarButtonBorder(context),
          width: 1,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('Galeri açılıyor...');
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 22.sp,
              color: AppTheme.getAppBarButtonColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              debugPrint('Etkinlik kaydediliyor...');
              Navigator.of(context).pop();
            },
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
                  LucideIcons.check400,
                  size: 25.sp,
                  color: AppTheme.getAppBarButtonColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
