import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/screens/main/home/home_screen.dart';
import 'package:lobi_application/screens/main/explore/explore_screen.dart';
import 'package:lobi_application/screens/main/events/events_screen.dart';
import 'package:lobi_application/screens/main/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.zinc700 : AppTheme.zinc300,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          selectedItemColor: AppTheme.purple900,
          unselectedItemColor: AppTheme.zinc600,
          selectedFontSize: 12.sp,
          unselectedFontSize: 11.sp,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24.sp),
              activeIcon: Icon(Icons.home, size: 24.sp),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 24.sp),
              activeIcon: Icon(Icons.explore, size: 24.sp),
              label: 'Keşfet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined, size: 24.sp),
              activeIcon: Icon(Icons.event, size: 24.sp),
              label: 'Etkinlik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24.sp),
              activeIcon: Icon(Icons.person, size: 24.sp),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}