import 'package:flutter/material.dart';
import 'permission.dart'; // Import PermissionsScreen

void main() {
  runApp(const MyApp());
}

// Global Theme Colors (Access these from any file using AppTheme.primary)
class AppTheme {
  static const Color primary = Color(0xFF0ABAB5); // Tiffany Blue
  static const Color light = Color(0xFFE0F7F6);   // Light wash
  static const Color dark = Color(0xFF007A74);    // Contrast text
  static const Color text = Color(0xFF2D3142);    // Dark Grey text
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckKawKaw',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FDFD),
        primaryColor: AppTheme.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          primary: AppTheme.primary,
          secondary: AppTheme.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppTheme.text),
          titleTextStyle: TextStyle(
            color: AppTheme.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppTheme.primary.withOpacity(0.4),
          ),
        ),
      ),
      // Start the app at the Permissions Screen defined in home_screen.dart
      home: const PermissionsScreen(),
    );
  }
}