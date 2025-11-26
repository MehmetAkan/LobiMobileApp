import 'package:flutter/material.dart';

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
