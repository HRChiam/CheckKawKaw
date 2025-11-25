import 'dart:convert'; // Import for JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'main.dart'; 
import 'analysisScreen.dart'; 

enum InputType { text, image, audio }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  InputType _inputType = InputType.text; 

  // REPLACE WITH YOUR IP. 
  // Android Emulator: 'http://10.0.2.2:3000'
  // iOS Simulator: 'http://localhost:3000'
  // Physical Device: 'http://192.168.1.XX:3000' (Your PC's IP)
  final String _baseUrl = 'http://10.0.2.2:3000'; 

  Future<void> _analyzeMessage() async {
    final message = _messageController.text.trim();

    if (_inputType == InputType.text && message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a message to check'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool isScam = false;
    double confidence = 0.0;
    String explanation = "";

    try {
      if (_inputType == InputType.text) {
        // --- REAL BACKEND CONNECTION ---
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
            if (lowerExp.contains('scam') || lowerExp.contains('suspicious') || lowerExp.contains('danger')) {
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
          explanation = "Failed to connect to server (Status: ${response.statusCode})";
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

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            message: message,
            isScam: isScam,
            confidence: confidence,
            explanation: explanation,
          ),
        ),
      );
    }
  }

  // ... (Rest of your UI code: _buildTypeButton, _buildInputArea, build method remain exactly the same)
  
  Widget _buildTypeButton(InputType type, String label, IconData icon) {
    final isSelected = _inputType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: isSelected
              ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
                ]
              : [],
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[500]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    if (_inputType == InputType.text) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: TextField(
          controller: _messageController,
          maxLines: 5,
          style: const TextStyle(color: AppTheme.text),
          decoration: InputDecoration(
            hintText: "Paste suspicious SMS here...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () => _messageController.clear(),
            ),
          ),
        ),
      );
    } else {
      final String uploadText =
          _inputType == InputType.image ? "Upload .png / .jpg" : "Upload .mp3";

      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("File picker opening... (Mock)")),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.light,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                uploadText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 50),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                   BoxShadow(color: Color(0x330ABAB5), blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("CheckKawKaw", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Secure Message Analysis", style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildInputArea(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildTypeButton(InputType.text, "Text", Icons.notes),
                      const SizedBox(width: 12),
                      _buildTypeButton(InputType.image, "Image", Icons.image_outlined),
                      const SizedBox(width: 12),
                      _buildTypeButton(InputType.audio, "Audio", Icons.mic_outlined),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeMessage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.radar, color: Colors.white),
                                SizedBox(width: 10),
                                Text("Analyze Scam",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}