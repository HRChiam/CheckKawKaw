import 'dart:io';
import 'dart:convert'; // Import for JSON
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'main.dart';
import 'analysisScreen.dart';
import '../services/api/text_api.dart';
import '../services/api/audio_api.dart';

enum InputType { text, image, audio }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  File? _selectedAudioFile;
  bool _isLoading = false;
  InputType _inputType = InputType.text;
  
  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, 
    );

    if (result != null) {
      setState(() {
        _selectedAudioFile = File(result.files.single.path!);
        _messageController.text = result.files.single.name; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected: ${result.files.single.name}")),
      );
    } else {
      // User canceled the picker
      print("User canceled audio picking");
    }
  }

  Future<void> _analyzeInput() async {
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
    if (_inputType == InputType.audio && _selectedAudioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload an audio file to check'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Default values (Fallbacks)
    String riskLevel = "Unknown";
    String scamType = "Unknown";
    String explanation = "Could not analyze message.";
    String recommendation = "Please try again later.";

    try {
      if (_inputType == InputType.text) {
        TextAPI result = await TextAPI.analyzeMessage(message);
        
        // Map result back to local variables
        riskLevel = result.riskLevel;
        scamType = result.scamType;
        explanation = result.explanation;
        recommendation = result.recommendation;

      } else if (_inputType == InputType.audio) {
        AudioAPI result = await AudioAPI.analyzeAudio(_selectedAudioFile!);
        riskLevel = result.riskLevel;
        scamType = result.scamType;
        explanation = result.explanation;
        recommendation = result.recommendation;

      }else {
        // Mock logic for Image/ (Keep as is for now)
        await Future.delayed(const Duration(milliseconds: 1500));
        riskLevel = "High";
        scamType = "Deepfake Audio";
        explanation = "Audio analysis detected synthetic voice patterns.";
        recommendation = "Do not trust this voice command. Verify caller identity.";
      }
    } catch (e) {
      explanation = "Error: $e";
      print("Error details: $e");
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            riskLevel: riskLevel,
            scamType: scamType,
            explanation: explanation,
            recommendation: recommendation,
          ),
        ),
      );
    }
  }
  
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
                      color: AppTheme.primary.withValues(alpha: 0.3),
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
              color: Colors.grey.withValues(alpha: 0.08),
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
    } else if (_inputType == InputType.audio && _selectedAudioFile != null) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
          color: AppTheme.primary, 
          width: 2,
        ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            // Center Content: Icon + Filename
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.audiotrack, size: 40, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _selectedAudioFile!.path.split('/').last, // Show Filename
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Top Right: Remove (X) Button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedAudioFile = null;
                    _messageController.clear(); // Clear the text controller too
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      String uploadText =
          _inputType == InputType.image ? "Upload .png / .jpg" : "Upload .mp3";

      IconData uploadIcon = Icons.add;
      Color iconColor = AppTheme.primary;
      Color boxColor = Colors.white;

      // 2. If a file is ALREADY selected (for Audio), change the UI to show it
      if (_inputType == InputType.audio && _selectedAudioFile != null) {
        uploadText = _selectedAudioFile!.path.split('/').last; // Show Filename
        uploadIcon = Icons.audiotrack; // Change Icon
        iconColor = Colors.white;
        boxColor = AppTheme.primary; // Make box solid color
      }

      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: InkWell(
          onTap: () {
            if ( _inputType == InputType.audio) {
              _pickAudioFile();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("File picker opening... (Mock)")),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.light,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.primary, size: 32),
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
              padding: const EdgeInsets.only(
                  top: 80, left: 24, right: 24, bottom: 50),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x330ABAB5),
                      blurRadius: 20,
                      offset: Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("CheckKawKaw",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Secure Message Analysis",
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
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
                      _buildTypeButton(
                          InputType.image, "Image", Icons.image_outlined),
                      const SizedBox(width: 12),
                      _buildTypeButton(
                          InputType.audio, "Audio", Icons.mic_outlined),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeInput,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
