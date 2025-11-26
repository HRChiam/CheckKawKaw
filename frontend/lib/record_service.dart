import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'call_recorder.dart';
import 'dart:isolate';

class RecordService {
  static Future start() async {
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
    await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_RecordTaskHandler());
}

class _RecordTaskHandler extends TaskHandler {
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    print("✅ Foreground service started");
  }

  @override
  void onButtonPressed(String id) {
    if (id == 'yes_record') {
      print("🎤 USER PRESSED YES — starting recording");
      CallRecorder.userApproved = true;
      CallRecorder.startRecording();
    }

    if (id == 'no_record') {
      print("🛑 USER PRESSED NO — stopping service");
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // optional — only runs if interval is set
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    print("🟡 Foreground service destroyed");
  }
}
