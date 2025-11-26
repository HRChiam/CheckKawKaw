import 'dart:convert';
import 'package:http/http.dart' as http;

class TextAPI {
  static Future<String?> detectScam(String message) async {
    final url = Uri.parse('http://192.168.0.5:3000/detect/text');
    //need to replace with your wifi ipv4

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'textMess': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'];
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Request failed: $e");
      return null;
    }
  }
}
