import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller (breathing effect)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 1.5 saniye
      vsync: this,
    )..repeat(reverse: true); // İleri-geri sonsuz döngü

    // Scale animation (0.9 to 1.1 - breathing effect)
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut, // Yumuşak geçiş
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.purple900,
      body: Stack(
        children: [
          // Background SVG overlay (0.65 opacity)
          Positioned.fill(
            child: Opacity(
              opacity: 0.65,
              child: SvgPicture.asset(
                'assets/images/system/background-splash.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Center scaling logo (breathing effect)
          Center(
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: SvgPicture.asset(
                'assets/images/system/logo/lobi-icon-white.svg',
                width: 120, // Logo boyutu
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
