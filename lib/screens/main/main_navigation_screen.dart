import 'package:flutter/material.dart';
import 'package:lobi_application/screens/main/home/home_screen.dart';
import 'package:lobi_application/screens/main/explore/explore_screen.dart';
import 'package:lobi_application/screens/main/events/events_screen.dart';
import 'package:lobi_application/screens/main/profile/profile_screen.dart';
import 'package:lobi_application/widgets/common/navbar/custom_navigation_bar.dart';
import 'package:lobi_application/widgets/common/banners/offline_banner.dart';
import 'package:lobi_application/widgets/navigation/tab_navigator.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // GlobalKeys for each tab's navigator (independent navigation stacks)
  final _homeNavigatorKey = GlobalKey<NavigatorState>();
  final _exploreNavigatorKey = GlobalKey<NavigatorState>();
  final _eventsNavigatorKey = GlobalKey<NavigatorState>();
  final _profileNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Wrap each screen with TabNavigator for independent navigation
    _screens = [
      TabNavigator(
        navigatorKey: _homeNavigatorKey,
        initialScreen: const HomeScreen(),
        tabName: 'Home',
      ),
      TabNavigator(
        navigatorKey: _exploreNavigatorKey,
        initialScreen: const ExploreScreen(),
        tabName: 'Explore',
      ),
      TabNavigator(
        navigatorKey: _eventsNavigatorKey,
        initialScreen: const EventsScreen(),
        tabName: 'Events',
      ),
      TabNavigator(
        navigatorKey: _profileNavigatorKey,
        initialScreen: const ProfileScreen(),
        tabName: 'Profile',
      ),
    ];
  }

  /// Get current tab's navigator key for back button handling
  GlobalKey<NavigatorState> _getCurrentNavigatorKey() {
    switch (_currentIndex) {
      case 0:
        return _homeNavigatorKey;
      case 1:
        return _exploreNavigatorKey;
      case 2:
        return _eventsNavigatorKey;
      case 3:
        return _profileNavigatorKey;
      default:
        return _homeNavigatorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Get current tab's navigator
        final navigatorKey = _getCurrentNavigatorKey();

        // If can pop in current tab, do it
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState!.pop();
          return false; // Don't exit app
        }

        // If on first screen, allow app exit
        return true;
      },
      child: Scaffold(
        extendBody: true,
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
