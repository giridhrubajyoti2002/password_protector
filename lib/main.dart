import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:password_protector/router.dart';
import 'package:password_protector/screens/home_screen.dart';

final isolates = IsolateHandler();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      onGenerateRoute: ((settings) => generateRoutes(settings)),
    );
  }
}
