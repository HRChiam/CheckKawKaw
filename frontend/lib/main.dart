import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'permission.dart';
import 'contacts_helper.dart';
import 'call_recorder.dart';
import 'record_service.dart';
import 'notification_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _initForegroundTask();
    listenToCallState();
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'recording_channel',
        channelName: 'Recording Service',
        channelDescription: 'Handles call recording requests',
        priority: NotificationPriority.HIGH,
        playSound: false,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
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
      final number = event["number"];

      if (state == "RINGING") {
        final exists = await ContactChecker.isInContacts(number);

        if (!exists) {
          print("🚨 Unknown number — showing popup");
          await NotificationService.showUnknownCaller(number);
          print("▶️ Starting foreground service...");
          await RecordService.start();
        }
      }


      if (state == "OFFHOOK" && CallRecorder.userApproved) {
        print("✅ Call answered — start recording");
        await CallRecorder.startRecording();
      }

      if (state == "IDLE") {
        CallRecorder.userApproved = false;
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