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
  static bool _isUploading = false; // ✅ Prevent overlapping uploads
  static String phone_call_state = "start";
  static String? phone_log_id;

  static Future<String> _newFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = "chunk_${DateTime.now().millisecondsSinceEpoch}.wav"; 
    return "${dir.path}/$fileName";
  }

  static Future startRecording() async {
    if (!userApproved) return;
    if (_isRecording) return;

    _timer?.cancel();
    _timer = null;
    _isRecording = true;
    _isUploading = false; // Reset upload flag

    if (!await _recorder.hasPermission()) {
      print("❌ No microphone permission");
      return;
    }

    final path = await _newFilePath();

    // 1. Start Recording
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav, 
        bitRate: 16000,            
        sampleRate: 8000,          
        numChannels: 1,            
      ),
      path: path,
    );

    print("🎤 Recording started → $path");
    phone_call_state = "start";
    phone_log_id = null; 

    // 2. Send First Chunk AND WAIT for ID
    // We do NOT start the timer yet. We wait for the backend to give us an ID.
    await sendChunk(first: true);

    // 3. Only start timer if we are still recording
    if (_isRecording) {
      _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
        phone_call_state = "middle";
        await sendChunk();
      });
    }
  }

  static Future sendChunk({bool first = false}) async {
    // ✅ Prevent overlap: If previous upload is still stuck, skip this beat
    if (_isUploading) {
      print("⏳ Previous upload still pending. Skipping this chunk...");
      return;
    }

    _isUploading = true; // Lock

    final prevPath = await _recorder.stop();

    if (prevPath == null) {
      print("⚠️ No chunk to send");
      _isUploading = false;
      return;
    }

    // Immediately start next recording
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

    // Upload
    final state = first ? "start" : "middle";
    final logId = phone_log_id ?? '';

    print("📤 Sending chunk ($state) | ID: $logId");

    try {
      final response = await UploadService.uploadFile(prevPath, phoneCallState: state, phoneLogId: logId);

      // ✅ CRITICAL: Capture ID
      if (response != null && response['phoneLogId'] != null) {
        phone_log_id = response['phoneLogId'].toString();
        print("📞 Updated phone_log_id: $phone_log_id");
      } else if (first) {
        print("❌ START FAILED: No ID returned. Retrying 'start' state next time.");
        // Keep state as 'start' so next chunk tries to get an ID again
        phone_call_state = "start"; 
      }

      if (response != null && response['send_alert'] == true) {
        String msg = response['caution_message'] ?? "High risk scam detected.";
        NotificationService.showHighRiskAlert(msg);
      }
    } catch (e) {
      print("🚨 Chunk Upload Error: $e");
    } finally {
      _isUploading = false; // Unlock
    }
  }

  static Future stopAndSendFinal() async {
    _timer?.cancel();
    _timer = null;
    _isRecording = false;

    final finalPath = await _recorder.stop();
    if (finalPath == null) return;

    print("✅ Sending Final Chunk");
    
    await UploadService.uploadFile(finalPath, phoneCallState: "end", phoneLogId: phone_log_id ?? '');
    
    phone_log_id = null;
    _isUploading = false;
  }
}