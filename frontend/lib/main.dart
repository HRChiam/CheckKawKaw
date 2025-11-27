import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'permission.dart';
import 'contacts_helper.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const callStateChannel = EventChannel('checkkawkaw/call_state');

void main() {
  runApp(const MyApp());
}

class AppTheme {
  static const Color primary = Color(0xFF0ABAB5);
  static const Color light = Color(0xFFE0F7F6);
  static const Color dark = Color(0xFF007A74);
  static const Color text = Color(0xFF2D3142);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.init();
    listenToCallState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MethodChannel("checkkawkaw/service").invokeMethod("startService");
    });

  }

  bool _initialized = false;   // <--- ADD THIS

  void listenToCallState() {
    callStateChannel.receiveBroadcastStream().listen((event) async {
      print("📞 CALL EVENT → $event");

      final state = event["state"];
      final number = event["number"];

      // 🛑 Ignore the first event — it's always IDLE on app start
      if (!_initialized) {
        _initialized = true;
        print("Skipping first call state event: $state");
        return;
      }

      // ================================
      // NORMAL LOGIC STARTS HERE
      // ================================

      if (state == "RINGING") {
        final exists = await ContactChecker.isInContacts(number);

        if (!exists) {
          NotificationService.showUnknownCaller(number);
          NotificationService.showCautionReminder();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('user_approved_record', false);
        }
      }

      if (state == "OFFHOOK") {
        for (int i = 0; i < 10; i++) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (state == "IDLE") {
        print("✔️ Real call ended → sending post-call reminder");
        NotificationService.showPostCallCheck();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_approved_record', false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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