import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class AppTextStyles {
  AppTextStyles._();
  static final authbuttonLg = GoogleFonts.figtree(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final authbuttonMd = GoogleFonts.figtree(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final body = GoogleFonts.figtree(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.zinc700,
  );

  static TextStyle get pageTitle => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  /// Ekran içi bölüm başlığı
  static TextStyle get sectionTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.40,
  );

  /// Kart başlığı
  static TextStyle get cardTitle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.20,
  );

  /// Normal gövde metni
  static TextStyle get bodyy => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: -0.05,
  );

  /// İkincil gövde metni
  static TextStyle get bodySecondary => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: -0.02,
  );

  /// Küçük bilgi / meta / tarih
  static TextStyle get caption => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.20,
  );

  /// Buton yazıları
  static TextStyle get button => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.20,
  );
  static TextStyle get titleHead_2XL => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.20,
  );
  static TextStyle get titleHead_XL => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.40,
  );
  static TextStyle get titleDesc_MD => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: -0.30,
  );
  static TextStyle get titleLG => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.20,
  );
  static TextStyle get titleMD => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.40,
  );
  static TextStyle get titleSM => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.20,
  );
  static TextStyle get titleXSM => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.20,
  );
  static TextStyle get titleXXSM => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.20,
  );
}
