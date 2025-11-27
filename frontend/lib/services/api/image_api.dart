import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import the url from config file
import '../ip.dart';

final String _baseUrl = configBaseUrl;

class ImageAPI {
  // These match the fields you were using in homeScreen.dart
  final String riskLevel;
  final String scamType;
  final String explanation;
  final String recommendation;

  ImageAPI({
    required this.riskLevel,
    required this.scamType,
    required this.explanation,
    required this.recommendation,
  });

  factory ImageAPI.error(String errorMessage) {
    return ImageAPI(
      riskLevel: "Unknown",
      scamType: "Unknown",
      explanation: errorMessage,
      recommendation: "Please try again later.",
    );
  }

  static Future<ImageAPI> analyzeImage(File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/detect/image/chunk');
      final request = http.MultipartRequest('POST', url);

      // Attach image file to form-data under fieldname "file"
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',            // <-- must match req.file.fieldname in backend
          imageFile.path,
        ),
      );

      // Send request
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);

   //     if (data['success'] == true && data['result'] != null) {
     //     final Map<String, dynamic> aiData = Map<String, dynamic>.from(data['result']);
if (data['result'] != null) {
    final aiData = Map<String, dynamic>.from(data['result']);
          // The parsing logic strictly moved from homeScreen.dart
          return ImageAPI(
            riskLevel: (aiData['risk_level'] ?? "Unknown").replaceAll('"', ''),
            scamType: (aiData['scam_type'] ?? "Unknown").replaceAll('"', ''),
            explanation: (aiData['explanation'] ?? "No explanation provided.").replaceAll('"', ''),
            recommendation: (aiData['recommendation'] ?? "Stay vigilant.").replaceAll('"', ''),
          );
        } else {
          return ImageAPI.error("Server error: ${data['error']}");
        }
      } else {
        return ImageAPI.error("Connection failed (Status: ${response.statusCode})");
      }
    } catch (e) {
      return ImageAPI.error("Error: $e");
    }
  }
}