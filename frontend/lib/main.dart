import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'permission.dart';
import 'contacts_helper.dart';
import 'call_recorder.dart';
import 'record_service.dart';
import 'notification_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
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
  String _currentCallState = "IDLE";

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _initForegroundTask();
    listenToCallState();

    FlutterForegroundTask.addTaskDataCallback((data) async {
      print("📨 DATA RECEIVED: $data");
      if (data == "USER_APPROVED_RECORDING") {
        print("✅ APPROVED RECEIVED IN MAIN THREAD");
        CallRecorder.userApproved = true;

        if (_currentCallState == "OFFHOOK") {
          print("⚡ Late Approval Detected — Starting Recording Immediately");
          await CallRecorder.startRecording();
        }
      }
    });
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ckk_recording_channel_v9',
        channelName: 'Recording Service',
        channelDescription: 'Handles call recording requests',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // ✅ FIX 1: 'interval' is removed. Use 'eventAction' instead.
        eventAction: ForegroundTaskEventAction.repeat(5000), 
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }


  void listenToCallState() {
    callStateChannel.receiveBroadcastStream().listen((event) async {
      print("📞 CALL EVENT → $event");

      final state = event["state"];

      _currentCallState = state;

      if (state == "RINGING") {
        // final exists = await ContactChecker.isInContacts(number);

        // if (!exists) {
          print("▶️ Starting foreground service...");
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('user_approved_record', false); 
          
          await RecordService.start();
        // }
      }


      if (state == "OFFHOOK") {
        print("📞 Call Answered — Checking for approval...");
        
        // 🔁 THE FIX: Check repeatedly for 5 seconds
        for (int i = 0; i < 10; i++) {
          final prefs = await SharedPreferences.getInstance();
          // Reload is CRITICAL to get fresh data from disk
          await prefs.reload(); 
          
          final isApproved = prefs.getBool('user_approved_record') ?? false;

          if (isApproved) {
            print("✅ Approval FOUND (Attempt ${i + 1}) — START RECORDING");
            CallRecorder.userApproved = true;
            await CallRecorder.startRecording();
            return; // Exit the loop, we are done!
          }
          
          print("⏳ Waiting for approval... (Attempt ${i + 1})");
          await Future.delayed(const Duration(milliseconds: 500)); // Wait 0.5s
        }

        print("❌ Approval timed out. Recording NOT started.");
      }

      if (state == "IDLE") {
        _currentCallState = "IDLE";
        CallRecorder.userApproved = false;
        
        // Reset storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_approved_record', false);

        await CallRecorder.stopAndSendFinal();
        await RecordService.stop();
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