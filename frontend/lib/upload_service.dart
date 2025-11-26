import 'dart:io';
import 'package:dio/dio.dart';

class UploadService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://your-backend-url.com", // ✅ change this!
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static Future<String?> uploadFile(String path, {bool isFinal = false}) async {
    try {
      final file = File(path);

      if (!file.existsSync()) {
        print("❌ File not found: $path");
        return null;
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

      final risk = response.data["risk"];
      print("🚨 Risk level from AI → $risk");

      await file.delete();
      print("🗑️ Deleted local file → $path");

      return risk;

    } catch (e) {
      print("🚨 Upload failed → $e");
    }
    return null;
  }
}
