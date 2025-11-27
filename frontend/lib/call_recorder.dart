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
  static bool _isUploading = false;
  static String? phone_log_id;

  static Future<String> _newFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    // ✅ Use WAV + 8000Hz (Magic Combo)
    final fileName = "chunk_${DateTime.now().millisecondsSinceEpoch}.wav"; 
    return "${dir.path}/$fileName";
  }

  static Future startRecording() async {
    if (!userApproved) return;
    if (_isRecording) return;

    _timer?.cancel();
    _timer = null;
    _isRecording = true;
    _isUploading = false;
    
    // Reset ID for the new call
    phone_log_id = null; 

    if (!await _recorder.hasPermission()) {
      print("❌ No microphone permission");
      return;
    }

    final path = await _newFilePath();

    // 1. Start Recording Immediately
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, 
        bitRate: 16000,            
        sampleRate: 8000,  // 8kHz = Small size
        numChannels: 1,    // Mono = Small size
      ),
      path: path,
    );

    print("🎤 Recording started → $path");

    // 🛑 CHANGE: Do NOT send an empty chunk here.
    // We just start the timer immediately.
    
    // 2. Start Timer (10s is safe for Free Plan)
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await sendChunk();
    });
  }

  static Future sendChunk() async {
    if (_isUploading) {
      print("⏳ Previous upload pending. Skipping overlap.");
      return;
    }

    _isUploading = true;

    // 1. Stop & Capture Audio
    final prevPath = await _recorder.stop();
    if (prevPath == null) {
      _isUploading = false;
      return;
    }

    // 2. Restart Recorder Immediately
    final newPath = await _newFilePath();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, 
        bitRate: 16000,   
        sampleRate: 8000, 
        numChannels: 1,   
      ),
      path: newPath,
    );

    // 3. Determine State Dynamically
    // If we don't have an ID yet, this MUST be the start.
    final String state = (phone_log_id == null) ? "start" : "middle";
    final String logIdToSen = phone_log_id ?? '';

    print("📤 Sending chunk ($state) | ID: $logIdToSen");

    try {
      final response = await UploadService.uploadFile(prevPath, phoneCallState: state, phoneLogId: logIdToSen);

      // Capture ID from backend
      if (response != null && response['phoneLogId'] != null) {
        phone_log_id = response['phoneLogId'].toString();
        print("📞 ID Synchronized: $phone_log_id");
      }

      // Check Alerts
      if (response != null && response['send_alert'] == true) {
        String msg = response['caution_message'] ?? "High risk scam detected.";
        NotificationService.showHighRiskAlert(msg);
      }
    } catch (e) {
      print("🚨 Upload Error: $e");
    } finally {
      _isUploading = false;
    }
  }

  static Future stopAndSendFinal() async {
    _timer?.cancel();
    _timer = null;
    _isRecording = false;

    final finalPath = await _recorder.stop();
    if (finalPath == null) return;

    print("✅ Sending Final Chunk");
    
    // Send 'end' state
    await UploadService.uploadFile(finalPath, phoneCallState: "end", phoneLogId: phone_log_id ?? '');
    
    phone_log_id = null;
    _isUploading = false;
  }
}