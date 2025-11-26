import 'dart:io';
import 'package:dio/dio.dart';

class UploadService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:3000", // Local backend
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static Future<Map<String, dynamic>?> uploadFile(String path, {required String phoneCallState, required String phoneLogId}) async {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        print("❌ File not found: $path");
        return null;
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          path,
          filename: path.split("/").last,
        ),
        'phone-call-state': phoneCallState,
        'phone-log-id': phoneLogId,
      });

      final response = await _dio.post(
        "/phone/chunk",
        data: formData,
      );

      print("✅ Uploaded successfully → ${response.statusCode}");
      print("🚨 Backend response → ${response.data}");

      await file.delete();
      print("🗑️ Deleted local file → $path");

      return response.data;
    } catch (e) {
      print("🚨 Upload failed → $e");
    }
    return null;
  }
}
