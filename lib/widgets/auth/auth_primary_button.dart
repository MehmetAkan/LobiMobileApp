import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  // Özelleştirilebilir alanlar:
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Default değerler:
    final Color resolvedBg = backgroundColor ?? AppTheme.black800;
    final Color resolvedTextColor = textColor ?? AppTheme.white;
    final double resolvedFontSize = fontSize ?? 17;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(50),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 22,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: resolvedFontSize,
                fontWeight: FontWeight.w600,
                color: resolvedTextColor,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
