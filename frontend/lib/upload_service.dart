import 'dart:io';
import 'package:dio/dio.dart';

class UploadService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://your-backend-url.com", // ✅ change this!
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 20),
    ),
  );

  static Future uploadFile(String path, {bool isFinal = false}) async {
    try {
      final file = File(path);

      if (!file.existsSync()) {
        print("❌ File not found: $path");
        return;
      }

      final formData = FormData.fromMap({
        'is_final': isFinal,
        'audio': await MultipartFile.fromFile(
          path,
          filename: path.split("/").last,
        ),
      });

      final response = await _dio.post(
        "/upload-audio",
        data: formData,
      );

      print("✅ Uploaded successfully → ${response.statusCode}");

      // ✅ delete file after upload
      await file.delete();
      print("🗑️ Deleted local file → $path");

    } catch (e) {
      print("🚨 Upload failed → $e");
    }
  }
}
