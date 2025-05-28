import 'package:dantri_clone/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.green.shade700,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
        ),
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
        // Custom DatePicker theme
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: Colors.green,
          headerForegroundColor: Colors.white,
          dayStyle: const TextStyle(color: Colors.black87),
          weekdayStyle: const TextStyle(color: Colors.black87),
          yearStyle: const TextStyle(color: Colors.black87),
          todayBackgroundColor: MaterialStateProperty.all(
            Colors.green.withOpacity(0.2),
          ),
          todayForegroundColor: MaterialStateProperty.all(Colors.green),
          dayOverlayColor: MaterialStateProperty.all(
            Colors.green.withOpacity(0.1),
          ),
          yearOverlayColor: MaterialStateProperty.all(
            Colors.green.withOpacity(0.1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        // Custom Dropdown theme
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.black87),
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.all(8),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        // Custom PopupMenu theme
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(color: Colors.black87),
        ),
        // Custom Dialog theme
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        // Custom SnackBar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.green,
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          insetPadding: const EdgeInsets.all(16),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
