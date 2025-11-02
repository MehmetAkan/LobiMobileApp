import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lobi_application/widgets/common/mixins/scrollable_page_mixin.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with ScrollablePageMixin {


  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.value;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'assets/images/system/other-page-bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.20),
              alignment: Alignment.bottomCenter,
            ),
          ),

          // İçerik
          SingleChildScrollView(
            controller: scrollController, // Mixin'den geliyor
            padding: EdgeInsets.fromLTRB(20.w, navbarHeight + 20.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile != null
                      ? 'HOŞGELDİN, ${profile.firstName.toUpperCase()}!'
                      : 'ANA SAYFAYA HOŞGELDİN',
                  textAlign: TextAlign.start,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 35.sp,
                    color: AppTheme.getTextHeadColor(context),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),

                if (profile != null)
                  Text(
                    'Yaş: ${profile.age} • ${profile.fullName}',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: AppTheme.getTextDescColor(context),
                    ),
                  ),

                SizedBox(height: 30.h),

                // Test kartları
                ...List.generate(
                  20,
                  (index) => Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Kart ${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              scrollController: scrollController, // Mixin'den geliyor
              leading: (scrolled) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isScrolled ? 35.h : 45.h, // Mixin'den geliyor
                    width: isScrolled ? 35.h : 45.h,
                    child: SvgPicture.asset(
                      'assets/images/system/lobi-icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          height: 1,
                          fontWeight: FontWeight.w500,
                          fontSize: isScrolled ? 14.sp : 15.sp,
                          color: AppTheme.getTextDescColor(context),
                        ),
                        child: const Text("Hoş Geldin,"),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          height: 1.2,
                          fontSize: isScrolled ? 16.sp : 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextHeadColor(context),
                        ),
                        child: Text(
                          profile != null
                              ? '${profile.firstName.toUpperCase()} ${profile.lastName.toUpperCase()}'
                              : 'OHH İSMİNİ BULAMADIK',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: (scrolled) => [
                LiquidGlassLayer(
                  child: LiquidGlass(
                    shape: LiquidRoundedSuperellipse(borderRadius: 60),
                    child: SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60.r),
                          child: Center(
                            child: Icon(
                              LucideIcons.bell400,
                              size: 22.sp,
                              color: AppTheme.getButtonIconColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
