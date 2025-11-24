import 'package:flutter/material.dart';

/// TabNavigator provides independent navigation stack for each bottom tab
/// Following Instagram/Twitter pattern for persistent bottom navigation
class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget initialScreen;
  final String tabName;

  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.initialScreen,
    required this.tabName,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => initialScreen,
          settings: settings,
        );
      },
    );
  }
}
