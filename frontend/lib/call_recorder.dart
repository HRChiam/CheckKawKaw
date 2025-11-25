import 'dart:async';
import 'upload_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class CallRecorder {
  static final AudioRecorder _recorder = AudioRecorder();
  static Timer? _timer;

  static bool userApproved = false;
  static bool _isRecording = false;

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
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );

    print("🎤 Recording started → $path");

    // ✅ every 30 seconds create chunk
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await sendChunk();
    });
  }

  static Future sendChunk() async {
    final prevPath = await _recorder.stop();

    if (prevPath == null) {
      print("⚠️ No chunk to send");
      return;
    }

    print("📤 Sending chunk → $prevPath");

    await UploadService.uploadFile(prevPath);

    // restart next chunk
    final newPath = await _newFilePath();

    await _recorder.start(
      RecordConfig(
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

    await UploadService.uploadFile(finalPath, isFinal: true);
  }

}
