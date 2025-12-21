import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final double? fontSize;
  final Color? backgroundColor;
  final BoxBorder? border;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.fontSize,
    this.backgroundColor,
    this.border,
  });

  String _getInitials() {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      // İki kelime varsa her ikisinin ilk harfi: "Mehmet Akan" → "MA"
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      // Tek kelime varsa ilk harf: "Mehmet" → "M"
      return words[0][0].toUpperCase();
    }
  }

  Color _generateColorFromName() {
    // İsimden hash oluştur
    final hash = name.hashCode;

    // Sabit renk paleti
    final colors = [
      AppTheme.blue800,
      AppTheme.purple900,
      AppTheme.red700,
      const Color(0xFF16A34A), // green
      const Color(0xFFEA580C), // orange
      const Color(0xFF0891B2), // cyan
      const Color(0xFFDB2777), // pink
      const Color(0xFF7C3AED), // violet
    ];

    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _generateColorFromName();
    final textSize = fontSize ?? (size * 0.4);

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? AppImage(
                path: imageUrl!,
                width: size.w,
                height: size.w,
                fit: BoxFit.cover,
                placeholder: _buildInitialsPlaceholder(bgColor, textSize),
              )
            : _buildInitialsPlaceholder(bgColor, textSize),
      ),
    );
  }

  Widget _buildInitialsPlaceholder(Color bgColor, double textSize) {
    return Container(
      width: size.w,
      height: size.w,
      color: bgColor,
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: textSize.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
