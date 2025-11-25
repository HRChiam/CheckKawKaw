import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Define Tiffany Blue Palette
  static const Color tiffanyPrimary = Color(0xFF0ABAB5); // Classic Tiffany
  static const Color tiffanyLight = Color(0xFFE0F7F6);   // Very light wash
  static const Color tiffanyDark = Color(0xFF007A74);    // Contrast text
  static const Color darkText = Color(0xFF2D3142);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckKawKaw',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FDFD), // Minty white bg
        primaryColor: tiffanyPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tiffanyPrimary,
          primary: tiffanyPrimary,
          secondary: tiffanyDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: darkText),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: tiffanyPrimary,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: tiffanyPrimary.withOpacity(0.4),
          ),
        ),
      ),
      home: const PermissionsScreen(),
    );
  }
}

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MyApp.tiffanyPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 40, color: MyApp.tiffanyPrimary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Permissions & Privacy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyApp.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "To detect scams accurately, CheckKawKaw needs the following permissions to analyze messages securely.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Permission List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: const [
                  PermissionItem(
                    icon: Icons.sms_outlined,
                    title: "SMS Messages",
                    description:
                        "Required to identify spam keywords and phishing links within your text messages.",
                  ),
                  PermissionItem(
                    icon: Icons.call_outlined,
                    title: "Phone Calls",
                    description:
                        "Helps identify known scam numbers and potential fraud calls in real-time.",
                  ),
                  PermissionItem(
                    icon: Icons.contacts_outlined,
                    title: "Contacts",
                    description:
                        "Used to whitelist your known contacts so we don't flag them as spam. Your contacts remain private.",
                  ),
                ],
              ),
            ),

            // Footer / Action Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      children: [
                        const TextSpan(text: "By tapping 'Agree & Continue', you accept our "),
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(
                            color: MyApp.tiffanyDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: MyApp.tiffanyDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: "."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Home Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text(
                        "Agree & Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const PermissionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyApp.tiffanyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MyApp.tiffanyDark, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyApp.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _analyzeMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a message to check'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulaton

    // Mock logic
    final isScam = message.toLowerCase().contains('click') ||
        message.toLowerCase().contains('verify') ||
        message.toLowerCase().contains('urgent') ||
        message.toLowerCase().contains('bank');

    final confidence = isScam ? 0.87 : 0.92; // Higher confidence for safe too
    final explanation = isScam
        ? 'We detected high-pressure language ("urgent", "verify") often used in phishing attempts to steal credentials.'
        : 'The message structure and vocabulary appear consistent with legitimate communication standards.';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // DECORATIVE HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 80, left: 24, right: 24, bottom: 50),
              decoration: const BoxDecoration(
                color: MyApp.tiffanyPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330ABAB5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "CheckKawKaw",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Secure Message Analysis",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // INPUT SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Analyze Suspicious Text",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyApp.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text Field Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      style: const TextStyle(color: MyApp.darkText),
                      decoration: InputDecoration(
                        hintText: "Paste the SMS or email here...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _messageController.clear(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // MAIN ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyApp.tiffanyPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.radar, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Analyze Scam",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // INFO SECTION
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: MyApp.tiffanyLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MyApp.tiffanyPrimary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: MyApp.tiffanyDark),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Privacy First",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: MyApp.tiffanyDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Your messages are analyzed locally and never stored on our servers.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MyApp.tiffanyDark,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisScreen extends StatelessWidget {
  final String message;
  final bool isScam;
  final double confidence;
  final String explanation;

  const AnalysisScreen({
    Key? key,
    required this.message,
    required this.isScam,
    required this.confidence,
    required this.explanation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on result
    final resultColor = isScam ? const Color(0xFFFF6B6B) : MyApp.tiffanyPrimary;
    final resultIcon = isScam ? Icons.gpp_bad_rounded : Icons.verified_user_rounded;
    final resultTitle = isScam ? "High Risk Detected" : "Appears Safe";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // RESULT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(resultIcon, size: 60, color: resultColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    resultTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(confidence * 100).toInt()}%",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // DETAILS SECTION
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Why this result?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.manage_search, color: MyApp.tiffanyPrimary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          explanation,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ORIGINAL MESSAGE PREVIEW
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Analyzed Content",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // BOTTOM BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: MyApp.tiffanyPrimary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Scan Another Message",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyApp.tiffanyPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}