import 'dart:async';
import 'upload_service.dart';
import 'notification_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class CallRecorder {
  static final AudioRecorder _recorder = AudioRecorder();
  static Timer? _timer;

  static bool userApproved = false;
  static bool _isRecording = false;
  static String phone_call_state = "start";
  static String? phone_log_id;

  static Future<String> _newFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = "chunk_${DateTime.now().millisecondsSinceEpoch}.m4a";
    return "${dir.path}/$fileName";
  }

  static Future startRecording() async {
    if (!userApproved) return;
    if (_isRecording) return;
    _isRecording = true;
    if (!await _recorder.hasPermission()) {
      print("❌ No microphone permission");
      return;
    }

    final path = await _newFilePath();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    print("🎤 Recording started → $path");
    phone_call_state = "start";
    phone_log_id = null;

    // Send the first chunk with state 'start' and no phone_log_id
    await sendChunk(first: true);

    // ✅ every 30 seconds create chunk
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      phone_call_state = "middle";
      await sendChunk();
    });
  }

  static Future sendChunk({bool first = false}) async {
    final prevPath = await _recorder.stop();

    if (prevPath == null) {
      print("⚠️ No chunk to send");
      return;
    }

    // Use 'start' for first chunk, 'middle' for others
    final state = phone_call_state;
    final logId = phone_log_id ?? '';

    print("📤 Sending chunk ($state) | ID: $logId");

    final response = await UploadService.uploadFile(prevPath, phoneCallState: state, phoneLogId: logId);

    // If backend generated a new phone_log_id, store it
    if (response != null && response['phoneLogId'] != null) {
      phone_log_id = response['phoneLogId'].toString();
      print("📞 Updated phone_log_id: $phone_log_id");
    }

    // Handle risk/analysis if present
    if (response != null && response['send_alert'] == true) {
      String msg = response['caution_message'] ?? "High risk scam detected.";
      print("🚨 ALERT TRIGGERED: $msg");
      // Pass the specific message to the notification
      NotificationService.showHighRiskAlert(msg);
    }

    // restart next chunk
    final newPath = await _newFilePath();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: newPath,
    );
  }

  static Future stopAndSendFinal() async {
    _timer?.cancel();
    _isRecording = false;

    final finalPath = await _recorder.stop();

    if (finalPath == null) {
      print("⚠️ No final recording");
      return;
    }

    print("✅ Final recording → $finalPath");
    phone_call_state = "end";

    final response = await UploadService.uploadFile(finalPath, phoneCallState: phone_call_state, phoneLogId: phone_log_id ?? '');

    if (response != null && response['send_alert'] == true) {
       String msg = response['caution_message'] ?? "High risk detected in final analysis.";
       NotificationService.showHighRiskAlert(msg);
    }
    
    phone_log_id = null;
  }
}
