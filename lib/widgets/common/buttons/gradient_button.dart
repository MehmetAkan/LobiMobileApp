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
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.borderRadius = 100,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
    this.textStyle,
    this.icon, // 🔹 opsiyonel icon
    this.iconGap = 8, // 🔹 icon ile yazı arası boşluk
  }) : assert(
         onPressed != null || routeName != null,
         'onPressed veya routeName parametresinden en az biri verilmelidir.',
       );

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

  /// Opsiyonel ikon (solda)
  final Widget? icon;

  /// Icon ile yazı arasındaki boşluk
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = (onPressed != null) || (routeName != null);

    final gradientColors =
        colors ?? const [AppTheme.purple900, AppTheme.purple500];

    // Disabled durumunda biraz soluklaştır
    final effectiveColors = isEnabled
        ? gradientColors
        : gradientColors.map((c) => c.withValues(alpha: 0.90)).toList();

    // 🔹 Label widget
    final labelWidget = Text(
      label,
      style:
          (textStyle ??
          const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
          )),
    );

    final childContent = icon == null
        ? labelWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              SizedBox(width: iconGap),
              labelWidget,
            ],
          );

    final buttonChild = Padding(
      padding: padding,
      child: Center(child: childContent),
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

    return SizedBox(width: expand ? double.infinity : null, child: content);
  }
}
