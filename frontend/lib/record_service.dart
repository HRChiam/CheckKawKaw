import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'call_recorder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Needed for Future

class RecordService {
  static Future start() async {
    print("🚀 RecordService: Requesting to start foreground service...");
    
    await FlutterForegroundTask.startService(
      notificationTitle: 'CheckKawKaw',
      notificationText: 'Tap YES to start recording',
      callback: startCallback,
      notificationButtons: const [
        NotificationButton(id: 'yes_record', text: 'YES'),
        NotificationButton(id: 'no_record', text: 'NO'),
      ],
    );
  }

  static Future stop() async {
    print("🛑 RecordService: Stopping foreground service...");
    await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_RecordTaskHandler());
}

class _RecordTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("✅ Foreground service started (v9)");
  }

  @override
  void onNotificationButtonPressed(String id) async { // ✅ Make async
    print("🖱️ BUTTON PRESSED: $id");

    if (id == 'yes_record') {
      print("🎤 USER PRESSED YES — Saving to Storage...");

      // 1. Save approval to 'disk' so Main App can see it
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_approved_record', true); // ✅ KEY CHANGE

      FlutterForegroundTask.updateService(
        notificationTitle: 'CheckKawKaw',
        notificationText: '🔴 Recording Call...',
        notificationButtons: [], 
      );
    }

    if (id == 'no_record') {
      print("🛑 USER PRESSED NO");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_approved_record', false); // ✅ Reset
      await CallRecorder.stopAndSendFinal();
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isSystemClosure) async {
    print("🟡 Foreground service destroyed");
  }
}