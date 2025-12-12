import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lobi_application/theme/app_text_styles.dart';

class AppTheme {
  /*Sabit Renkler*/
  static const Color white = Color(0xFFFFFFFF);
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
  // GREEN
  static const Color green50 = Color(0xFFF2FDF0);
  static const Color green100 = Color(0xFFE1FCDC);
  static const Color green200 = Color(0xFFC3F7BB);
  static const Color green300 = Color(0xFF94EF86);
  static const Color green400 = Color(0xFF5DDE4A);
  static const Color green500 = Color(0xFF33BA20);
  static const Color green600 = Color(0xFF27A316);
  static const Color green700 = Color(0xFF228015);
  static const Color green800 = Color(0xFF1F6516);
  static const Color green900 = Color(0xFF1A5314);
  static const Color green950 = Color(0xFF082E05);

  // RED
  static const Color red50 = Color(0xFFFFF0F0);
  static const Color red100 = Color(0xFFFFDDDD);
  static const Color red200 = Color(0xFFFFC1C2);
  static const Color red300 = Color(0xFFFF9798);
  static const Color red400 = Color(0xFFFF5B5C);
  static const Color red500 = Color(0xFFFF282A);
  static const Color red600 = Color(0xFFFA080A);
  static const Color red700 = Color(0xFFE00204);
  static const Color red800 = Color(0xFFAE0608);
  static const Color red900 = Color(0xFF8F0D0E);
  static const Color red950 = Color(0xFF4F0001);

  // ORANGE
  static const Color orange50 = Color(0xFFFFF8EC);
  static const Color orange100 = Color(0xFFFFF0D3);
  static const Color orange200 = Color(0xFFFFDDA5);
  static const Color orange300 = Color(0xFFFFC46D);
  static const Color orange400 = Color(0xFFFF9F32);
  static const Color orange500 = Color(0xFFFF810A);
  static const Color orange600 = Color(0xFFF06200);
  static const Color orange700 = Color(0xFFCC4A02);
  static const Color orange800 = Color(0xFFA13A0B);
  static const Color orange900 = Color(0xFF82320C);
  static const Color orange950 = Color(0xFF461604);

  // PURPLE
  static const Color purple50 = Color(0xFFF1F0FF);
  static const Color purple100 = Color(0xFFE7E4FF);
  static const Color purple200 = Color(0xFFD1CCFF);
  static const Color purple300 = Color(0xFFAFA4FF);
  static const Color purple400 = Color(0xFF8970FF);
  static const Color purple500 = Color(0xFF6412C6);
  static const Color purple600 = Color(0xFF550FFF);
  static const Color purple700 = Color(0xFF4600FF);
  static const Color purple800 = Color(0xFF3A00DA);
  static const Color purple900 = Color(0xFF2E00A7);
  static const Color purple950 = Color(0xFF1A007A);

  // BERMUDA
  static const Color bermuda50 = Color(0xFFECFDF7);
  static const Color bermuda100 = Color(0xFFD2F9EA);
  static const Color bermuda200 = Color(0xFFA8F2D9);
  static const Color bermuda300 = Color(0xFF67E4C2);
  static const Color bermuda400 = Color(0xFF36D1AB);
  static const Color bermuda500 = Color(0xFF12B795);
  static const Color bermuda600 = Color(0xFF07947A);
  static const Color bermuda700 = Color(0xFF057764);
  static const Color bermuda800 = Color(0xFF075E51);
  static const Color bermuda900 = Color(0xFF074D44);
  static const Color bermuda950 = Color(0xFF032B27);

  // AZURE
  static const Color azure50 = Color(0xFFF0F7FE);
  static const Color azure100 = Color(0xFFDDEDFC);
  static const Color azure200 = Color(0xFFC3E0FA);
  static const Color azure300 = Color(0xFF99CEF7);
  static const Color azure400 = Color(0xFF69B3F1);
  static const Color azure500 = Color(0xFF4695EB);
  static const Color azure600 = Color(0xFF3B7FE1);
  static const Color azure700 = Color(0xFF2863CD);
  static const Color azure800 = Color(0xFF2651A7);
  static const Color azure900 = Color(0xFF244684);
  static const Color azure950 = Color(0xFF1B2C50);
  // BLUE
  static const Color blue50 = Color(0xFFEFF8FF);
  static const Color blue100 = Color(0xFFDAEEFF);
  static const Color blue200 = Color(0xFFBEE2FF);
  static const Color blue300 = Color(0xFF91D1FF);
  static const Color blue400 = Color(0xFF5DB6FD);
  static const Color blue500 = Color(0xFF3092F9);
  static const Color blue600 = Color(0xFF2278EE);
  static const Color blue700 = Color(0xFF1A61DB);
  static const Color blue800 = Color(0xFF1B4FB2);
  static const Color blue900 = Color(0xFF1C458C);
  static const Color blue950 = Color(0xFF162B55);
  // CRETE
  static const Color crete50 = Color(0xFFF7F7EE);
  static const Color crete100 = Color(0xFFEDECDA);
  static const Color crete200 = Color(0xFFDCDCBA);
  static const Color crete300 = Color(0xFFC5C690);
  static const Color crete400 = Color(0xFFAEAF6C);
  static const Color crete500 = Color(0xFF91934F);
  static const Color crete600 = Color(0xFF72753C);
  static const Color crete700 = Color(0xFF575A31);
  static const Color crete800 = Color(0xFF47492B);
  static const Color crete900 = Color(0xFF3C3F28);
  static const Color crete950 = Color(0xFF1F2112);
  // CITRON
  static const Color citron50 = Color(0xFFFFFDE5);
  static const Color citron100 = Color(0xFFFFFFC8);
  static const Color citron200 = Color(0xFFFEFF97);
  static const Color citron300 = Color(0xFFF5FB5B);
  static const Color citron400 = Color(0xFFE9F229);
  static const Color citron500 = Color(0xFFCAD80A);
  static const Color citron600 = Color(0xFF96A303);
  static const Color citron700 = Color(0xFF778308);
  static const Color citron800 = Color(0xFF5E670D);
  static const Color citron900 = Color(0xFF4E5710);
  static const Color citron950 = Color(0xFF2A3102);

  static const Color black800 = Color(0xFF090A0A);
  static const Color backgroundLight = Color.fromARGB(255, 255, 255, 255);
  static const Color backgroundDark = Color(0xFF090A0A);
  static const Color dark_zinc200 = Color(0xFFF2F2F2);
  static const Color dark_zinc300 = Color(0xFFBEBEBE);
  static const Color dark_zinc400 = Color(0xFF636367);
  static const Color dark_zinc500 = Color(0xFF515155);
  static const Color dark_zinc600 = Color(0xFF404043);
  static const Color dark_zinc700 = Color(0xFF303033);
  static const Color dark_zinc800 = Color(0xFF1D1D1F);
  static const Color dark_zinc900 = Color(0xFF141415);
  static const Color navbarLight = Color(0xFFFFFFFF);
  static const Color navbarDark = Color.fromARGB(255, 0, 0, 0);

  static Color getButtonIconBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : white;
  }

  static Color getButtonIconColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getTextNavigationColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc600;
  }

  static Color getButtonIconBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : zinc100;
  }

  static Color getNavbarBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getNavbarBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc200;
  }

  static Color getNavbarDateDescText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? zinc600
        : zinc600;
  }

  static Color getNavbarBtnBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getNavbarBtnBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : zinc100;
  }

  static Color getNavbarBtnActiveBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : purple900;
  }

  static Color getNavbarBtnActiveBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getNavbarBtnActiveText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : white;
  }

  static Color getTextHeadColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getTextDescColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc600;
  }

  static Color getListUsernameColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc600;
  }

  static Color getEventCardOrganizerBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800
        : white;
  }

  static Color getTextModalDescColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc700;
  }

  static Color getCardColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc800;
  }

  static Color getHomeButtonBgColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : white;
  }

  static Color getModalIconBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getModalIconBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getModalIconText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getHomeButtonTextColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getHomeButtonBorderColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc200;
  }

  static Color getEventIconColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc600;
  }

  static Color getEventListDivider(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getProfileDivider(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc200;
  }

  static Color getNotificationText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getProfileDividerActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getEventIconTextColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc800;
  }

  static Color getnNavigationBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc100;
  }

  static Color getnNavigationBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getNavigationBtnBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getnNavigationActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc100;
  }

  static Color getTextNavigationActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getCategoryCardBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc300;
  }

  static Color getCategoryButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getCategoryButtonBgActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc300;
  }

  static Color getCategoryButtonBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : black800;
  }

  static Color getCategoryButtonBorderActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc400;
  }

  static Color getCategoryButtonText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800
        : white;
  }

  static Color getCategoryButtonTextActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getCategoryCardBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : white;
  }

  static Color getSwitchText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getSwitchBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc100;
  }

  static Color getSettingsCheckButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc400;
  }

  static Color getSettingsCheckButtonBgActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getModalBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : zinc100;
  }

  static Color getModalButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getModalButtonText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getModalListDivider(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc300;
  }

  static Color getSwitchBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getSwitchActive(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc400;
  }

  static Color getFilterText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : black800;
  }

  static Color getFilterActiveText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : purple900;
  }

  static Color getAppBarBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : black800;
  }

  static Color getEventAppBarButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800.withOpacity(0.2)
        : black800.withOpacity(0.2);
  }

  static Color getEventAppBarButtonBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600.withOpacity(0.5)
        : dark_zinc600.withOpacity(0.5);
  }

  static Color getAppBarButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800.withOpacity(0.2)
        : black800.withOpacity(0.2);
  }

  static Color getAppBarButtonBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600.withOpacity(0.5)
        : dark_zinc600.withOpacity(0.5);
  }

  static Color getCreateEventBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800
        : black800;
  }

  static Color getAppBarTextColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : white;
  }

  static Color getAppBarTextColorSecondary(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getAppBarButtonBorderColorSecondary(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getAppBarButtonBgColorSecondary(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200.withValues(alpha: 0.7);
  }

  static Color getSettingsCardBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getSettingsProfileLabel(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc700;
  }

  static Color getSettingsProfileHint(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc500
        : zinc600;
  }

  static Color getSettingsProfileSmallHead(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc600;
  }

  static Color getSettingsCardBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getSettingsCardDivider(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc600
        : zinc400;
  }

  static Color getSettingsCardIcon(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getSettingsLogout(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? red500
        : red700;
  }

  static Color getLogoutModalIconBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? red700
        : red50;
  }

  static Color getLogoutModalIconBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? red700
        : red100;
  }

  static Color getLogoutModalIconText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : red700;
  }

  static Color getSettingsCardArrowIcon(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc500
        : zinc600;
  }

  static Color getSettingsCardText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getAppBarButtonColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : white;
  }

  static Color getEventFieldBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800.withOpacity(0.5)
        : black800.withOpacity(0.5);
  }

  static Color getEventFieldBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : dark_zinc800.withOpacity(0.2);
  }

  static Color getEventFieldPlaceholder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : white.withOpacity(0.6);
  }

  static Color getEventFieldText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : white;
  }

  static Color getAuthIconBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : zinc200;
  }

  static Color getAuthIconColor(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc200
        : zinc800;
  }

  static Color getAuthHeadText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc200
        : black800;
  }

  static Color getAuthDescText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc800;
  }

  static Color getAuthInputBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc200;
  }

  static Color getAuthCardBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : zinc300;
  }

  static Color getAuthCarText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc700;
  }

  static Color getAuthCategoryBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc800
        : white;
  }

  static Color getAuthCategoryBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getAuthCategoryText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc700;
  }

  static Color getAuthCategoryTextSelected(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? white
        : black800;
  }

  static Color getAuthCategoryBgSelected(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc900
        : zinc100;
  }

  static Color getAuthInputText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc200
        : black800;
  }

  static Color getAuthInputBorder(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc700
        : zinc300;
  }

  static Color getAuthInputBorderFocus(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc400;
  }

  static Color getAuthInputHint(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc400
        : zinc600;
  }

  static Color getAuthButtonBg(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? zinc200
        : black800;
  }

  static Color getAuthButtonText(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? black800
        : white;
  }

  static Color getAuthBackButton(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? dark_zinc300
        : zinc800;
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
    brightness: Brightness.light,
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
      systemOverlayStyle:
          SystemUiOverlayStyle.dark, // Status bar icons dark (for light bg)
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
    brightness: Brightness.dark,
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
      systemOverlayStyle:
          SystemUiOverlayStyle.light, // Status bar icons light (for dark bg)
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
