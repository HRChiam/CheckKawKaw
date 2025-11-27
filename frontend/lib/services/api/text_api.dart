import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ip.dart';

final String _baseUrl = configBaseUrl;

class TextAPI {
  // These match the fields you were using in homeScreen.dart
  final String riskLevel;
  final String scamType;
  final String explanation;
  final String recommendation;

  TextAPI({
    required this.riskLevel,
    required this.scamType,
    required this.explanation,
    required this.recommendation,
  });

  factory TextAPI.error(String errorMessage) {
    return TextAPI(
      riskLevel: "Unknown",
      scamType: "Unknown",
      explanation: errorMessage,
      recommendation: "Please try again later.",
    );
  }

  static Future<TextAPI> analyzeMessage(String message) async {
    try {
      final url = Uri.parse('$_baseUrl/detect/text');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"textMess": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['result'] != null) {
          final Map<String, dynamic> aiData = Map<String, dynamic>.from(data['result']);

          // The parsing logic strictly moved from homeScreen.dart
          return TextAPI(
            riskLevel: (aiData['risk_level'] ?? "Unknown").replaceAll('"', ''),
            scamType: (aiData['scam_type'] ?? "Unknown").replaceAll('"', ''),
            explanation: (aiData['explanation'] ?? "No explanation provided.").replaceAll('"', ''),
            recommendation: (aiData['recommendation'] ?? "Stay vigilant.").replaceAll('"', ''),
          );
        } else {
          return TextAPI.error("Server error: ${data['error']}");
        }
      } else {
        return TextAPI.error("Connection failed (Status: ${response.statusCode})");
      }
    } catch (e) {
      return TextAPI.error("Error: $e");
    }
  }
}