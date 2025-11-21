import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_text_styles.dart';

class AppTheme {
  /*Sabit Renkler*/
  static const Color white = Color(0xFFFFFFFF);
  static const Color purple100 = Color(0xFFF4F2FB);
  static const Color purple900 = Color(0xFF2E00A7);
  static const Color purple800 = Color(0xFF6412C6);
  static const Color zinc100 = Color(0xFFFAFAFA);
  static const Color zinc200 = Color(0xFFF7F7F7);
  static const Color zinc300 = Color(0xFFEDEDED);
  static const Color zinc400 = Color(0xFFE2E2E2);
  static const Color zinc500 = Color(0xFFB4B4B4);
  static const Color zinc600 = Color(0xFF909090);
  static const Color zinc700 = Color(0xFF727272);
  static const Color zinc800 = Color(0xFF636363);
  static const Color zinc900 = Color(0xFF3E3E3E);
  static const Color zinc1000 = Color(0xFF292929);
  static const Color green100 = Color(0xFFE5F7E8);
  static const Color green800 = Color(0xFF06df73);
  static const Color green900 = Color(0xFF33BA20);
  static const Color red100 = Color(0xFFF9E5E5);
  static const Color red800 = Color(0xFFE00303);
  static const Color red900 = Color(0xFFCB0200);
  static const Color orange100 = Color(0xFFFFFBEA);
  static const Color orange200 = Color(0xFFffedd4);
  static const Color orange900 = Color(0xFFF46400);
  static const Color blue100 = Color(0xFFE0F2FE);
  static const Color blue800 = Color(0xFF075985);
  static const Color black800 = Color(0xFF090A0A);
  static const Color backgroundLight = Color.fromARGB(255, 255, 255, 255);
  static const Color backgroundDark = Color(0xFF090A0A);
  static const Color dark_zinc600 = Color(0xFFB2B2B2);
  static const Color dark_zinc700 = Color(0xFF949293);
  static const Color dark_zinc800 = Color(0xFF1D1D1F);
  static const Color navbarLight = Color(0xFFFFFFFF);
  static const Color navbarDark = Color.fromARGB(255, 0, 0, 0);
  /*Sabit Renkler*/

  static Color getButtonIconBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc800
        : white;
  }

  static Color getButtonIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? white : black800;
  }

  static Color getButtonIconBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc100;
  }

  static Color getNavbarBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getNavbarBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc100;
  }

  static Color getNavbarDateDescText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? zinc600 : zinc600;
  }

  static Color getNavigationBtnBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc300;
  }

  static Color getNavbarBtnBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc200;
  }

  static Color getNavbarBtnBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc100;
  }

  static Color getNavbarBtnActiveBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : purple900;
  }

  static Color getNavbarBtnActiveBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getNavbarBtnActiveText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getTextHeadColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundLight
        : black800;
  }

  static Color getTextDescColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc600;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc800;
  }

  static Color getHomeButtonBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getHomeButtonTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getHomeButtonBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc200;
  }

  static Color getEventIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc600;
  }

  static Color getEventIconTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? zinc800 : zinc800;
  }

  static Color getnNavigationBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getnNavigationBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc100;
  }

  static Color getCategoryCardBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc800
        : zinc300;
  }

  static Color getCategoryCardBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getSwitchText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getSwitchBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getSwitchBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc200;
  }

  static Color getSwitchActive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc300;
  }

  static Color getFilterText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getFilterActiveText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : purple900;
  }

  static Color getAppBarBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getAppBarButtonBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : black800.withOpacity(0.2);
  }

  static Color getAppBarButtonBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? zinc400
        : dark_zinc600.withOpacity(0.5);
  }

  static Color getCreateEventBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? black800
        : black800;
  }

  static Color getAppBarTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? black800 : white;
  }

  static Color getAppBarTextColorSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? white : black800;
  }

  static Color getAppBarButtonBorderColorSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getAppBarButtonBgColorSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : zinc200.withValues(alpha: 0.7);
  }

  static Color getAppBarButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? black800 : white;
  }

  static Color getEventFieldBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : black800.withOpacity(0.5);
  }

  static Color getEventFieldBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : dark_zinc800.withOpacity(0.2);
  }

  static Color getEventFieldPlaceholder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? white
        : white.withOpacity(0.6);
  }

  static Color getModalButtonBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc700
        : zinc200;
  }

  static Color getModalButtonText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getEventFieldText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? white : white;
  }

  static String? get _platformFontFamily {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // iOS ve macOS'ta sistem fontu (SF Pro) kullanılsın
        return null;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      default:
        // Android tarafında Roboto (sistem fontu)
        return 'Roboto';
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // fontFamily: 'Figtree',
    fontFamily: _platformFontFamily,
    scaffoldBackgroundColor: backgroundLight,
    textTheme: TextTheme(
      titleLarge: AppTextStyles.pageTitle,
      titleMedium: AppTextStyles.sectionTitle,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySecondary,
      labelLarge: AppTextStyles.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(size: 22),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: _platformFontFamily,
    scaffoldBackgroundColor: backgroundDark,
    textTheme: TextTheme(
      titleLarge: AppTextStyles.pageTitle,
      titleMedium: AppTextStyles.sectionTitle,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySecondary,
      labelLarge: AppTextStyles.button,
    ),
    iconTheme: const IconThemeData(size: 22),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: purple900,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
}
