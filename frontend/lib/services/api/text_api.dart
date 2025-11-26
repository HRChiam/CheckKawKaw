import 'package:http/http.dart' as http;
import 'dart:convert';

// REPLACE WITH YOUR IP.
// Android Emulator: 'http://10.0.2.2:3000'
// iOS Simulator: 'http://localhost:3000'
// Physical Device / run via USB debugging: (Your PC's IP):3000
final String _baseUrl = 'http://192.168.0.5:3000';

class TextAPI {
  //declare the item that needs to be returned in this function
  String explanation;
  bool isScam;
  double confidence;

  TextAPI({
    required this.explanation,
    required this.isScam,
    required this.confidence,
  });

  static Future <TextAPI> detectTextScam(String message) async {
    String explanation = "";
    bool isScam = false;
    double confidence = 0.0;
    try {
      //i modify this line a bit the if (_inputType == InputType.text)
      if (message != "") {

        final url = Uri.parse('$_baseUrl/detect/text');

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"textMess": message}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            explanation = data['result']; // The AI text from JamAI

            // Simple logic to set boolean based on AI explanation keywords
            // You might want to ask JamAI to return a boolean JSON in the future
            final lowerExp = explanation.toLowerCase();
            if (lowerExp.contains('scam') ||
                lowerExp.contains('suspicious') ||
                lowerExp.contains('danger')) {
              isScam = true;
              confidence = 0.95;
            } else {
              isScam = false;
              confidence = 0.90;
            }
          } else {
            explanation = "Server returned an error: ${data['error']}";
          }
        } else {
          explanation =
              "Failed to connect to server (Status: ${response.statusCode})";
        }
      } else {
        // Mock logic for Image/Audio (Not implemented in backend yet)
        await Future.delayed(const Duration(milliseconds: 1500));
        isScam = true;
        confidence = 0.75;
        explanation = "Image/Audio analysis not yet connected to backend.";
      }
    } catch (e) {
      explanation = "Connection Error: $e";
      isScam = false;
      confidence = 0.0;
    }
    return TextAPI(
      explanation: explanation,
      isScam: isScam,
      confidence: confidence,
    );
  }
}
