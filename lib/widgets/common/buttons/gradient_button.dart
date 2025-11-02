import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.routeName,
    this.expand = true,
    this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.borderRadius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.textStyle,
  }) : assert(onPressed != null || routeName != null,
          'onPressed veya routeName parametresinden en az biri verilmelidir.');

  final String label;
  final VoidCallback? onPressed;
  final String? routeName;

  /// Genişliği tam olsun mu?
  final bool expand;

  /// Gradyan renkleri (vermezsen varsayılan AppTheme tonları kullanılır)
  final List<Color>? colors;

  /// Gradyan yönü
  final Alignment begin;
  final Alignment end;

  /// Köşe yarıçapı (AppTheme ile uyumlu)
  final double borderRadius;

  /// İç boşluk
  final EdgeInsetsGeometry padding;

  /// Yazı stilini ezmek istersen
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = (onPressed != null) || (routeName != null);

    final gradientColors = colors ??
        const [AppTheme.purple800, AppTheme.purple900];

    // Disabled durumunda biraz soluklaştır
    final effectiveColors = isEnabled
        ? gradientColors
        : gradientColors.map((c) => c.withOpacity(0.5)).toList();

    final buttonChild = Padding(
      padding: padding,
      child: Center(
        child: Text(
          label,
          style: (textStyle ??
              TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: Colors.white,
              )),
        ),
      ),
    );

    void handleTap() {
      if (!isEnabled) return;
      if (onPressed != null) {
        onPressed!();
        return;
      }
      if (routeName != null) {
        Navigator.of(context).pushNamed(routeName!);
      }
    }

    final content = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveColors,
            begin: begin,
            end: end,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isEnabled ? handleTap : null,
          child: buttonChild,
        ),
      ),
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: content,
    );
  }
}
