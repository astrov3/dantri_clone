import 'package:dantri_clone/router/router.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DanTriApp());
}

class DanTriApp extends StatelessWidget {
  const DanTriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dân trí',
      theme: ThemeData(
        primaryColor: Colors.green,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
