import 'package:flutter/material.dart';
import 'package:password_protector/screens/error_screen.dart';
import 'package:password_protector/screens/results_screen.dart';
import 'package:password_protector/screens/home_screen.dart';

Route<dynamic>? generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case HomeScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          final map = settings.arguments as Map<String, dynamic>;
          int tabIndex = map['tabIndex'] as int;
          String filePath = map['filePath'] as String;
          return HomeScreen(
            tabIndex: tabIndex,
            filePath: filePath,
          );
        },
      );
    case ResultsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) {
          return const ResultsScreen();
        },
      );
  }
  return MaterialPageRoute(
    builder: (context) {
      final error = settings.arguments as String;
      return ErrorScreen(error: error);
    },
  );
}
