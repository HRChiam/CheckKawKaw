import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ip.dart';

final String _baseUrl = configBaseUrl;

class AudioAPI {
  final String riskLevel;
  final String scamType;
  final String explanation;
  final String recommendation;

  AudioAPI({
    required this.riskLevel,
    required this.scamType,
    required this.explanation,
    required this.recommendation,
  });

  factory AudioAPI.error(String errorMessage) {
    return AudioAPI(
      riskLevel: "Unknown",
      scamType: "Unknown",
      explanation: errorMessage,
      recommendation: "Please try again later.",
    );
  }

  static Future<AudioAPI> analyzeAudio(File audioFile) async {
    try {
      final url = Uri.parse('$_baseUrl/detect/audio/chunk');
      var request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        audioFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dynamic resultData = data;

        if (data is Map && data.containsKey('result')) {
           resultData = data['result'];
        }

        if (resultData != null) {
          final Map<String, dynamic> aiData = Map<String, dynamic>.from(resultData);

          return AudioAPI(
            riskLevel: (aiData['risk_level'] ?? "Unknown").toString().replaceAll('"', ''),
            scamType: (aiData['scam_type'] ?? "Unknown").toString().replaceAll('"', ''),
            explanation: (aiData['explanation'] ?? "No explanation provided.").toString().replaceAll('"', ''),
            recommendation: (aiData['recommendation'] ?? "Stay vigilant.").toString().replaceAll('"', ''),
          );
        } else {
          return AudioAPI.error("Server returned empty results.");
        }
      } else {
        return AudioAPI.error("Upload failed (Status: ${response.statusCode})");
      }
    } catch (e) {
      return AudioAPI.error("Error sending audio: $e");
    }
  }
}