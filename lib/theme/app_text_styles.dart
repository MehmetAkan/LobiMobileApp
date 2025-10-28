import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class AppTextStyles {
  // Button text
  static final authbuttonLg = GoogleFonts.urbanist(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final authbuttonMd = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Headline (büyük başlık)
  // static final headline = GoogleFonts.urbanist(
  //   fontSize: 28,
  //   fontWeight: FontWeight.w700,
  //   color: AppTheme.zinc900,
  // );

  // Body (normal paragraf)
  static final body = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.zinc700,
  );
}
