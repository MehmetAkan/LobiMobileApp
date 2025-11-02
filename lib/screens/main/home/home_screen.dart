import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navbar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLogoSmall = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final shouldBeSmall = offset > 10;

    if (shouldBeSmall != _isLogoSmall) {
      setState(() {
        _isLogoSmall = shouldBeSmall;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final profileState = ref.watch(currentUserProfileProvider);
    final profile = profileState.value;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final navbarHeight = 60.h + statusBarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/system/other-page-bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.20),
              alignment: Alignment.bottomCenter,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController, // Direkt controller kullan
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
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.black800,
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
                      color: AppTheme.zinc600,
                    ),
                  ),

                SizedBox(height: 30.h),

                ...List.generate(
                  20,
                  (index) => Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    width: 400,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppTheme.dark_zinc800
                          : AppTheme.green900,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Kart ${index + 1}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.green900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavbar(
              scrollController: _scrollController, 
              leading: (isScrolled) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isLogoSmall ? 35.h : 45.h,
                    width: _isLogoSmall ? 35.h : 45.h,
                    child: SvgPicture.asset(
                      'assets/images/system/lobi-icon.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 5),
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
                          fontSize: _isLogoSmall ? 14.sp : 15.sp,
                          color: AppTheme.getTextDescColor(context),
                        ),
                        child: Text("Hoş Geldin,"),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          height: 1.2,
                          fontSize: _isLogoSmall ? 16.sp : 18.sp,
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
              actions: (isScrolled) => [
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
