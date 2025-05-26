import 'package:dantri_clone/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';  // nhớ import provider
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'viewmodels/category_viewmodel.dart'; // import viewmodel nếu cần



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const DanTriApp());
}

class DanTriApp extends StatelessWidget {
  const DanTriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel(),
      child:  MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dân trí',
      theme: ThemeData(
        primaryColor: Colors.green,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF4CAF50), // Màu con trỏ (caret)
          selectionColor: Color(
            0x334CAF50,
          ), // Màu nền khi chọn văn bản (với alpha mờ)
          selectionHandleColor: Color(0xFF4CAF50), // Màu của nút kéo chọn
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      routerConfig: AppRouter.router,
    )
    );
  }
}
