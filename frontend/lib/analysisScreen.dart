import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'main.dart'; // To access AppTheme

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
    // Safety score calculation
    final double safetyScore = isScam ? (1.0 - confidence) : confidence;
    
    final Color statusColor = isScam ? const Color(0xFFFF6B6B) : AppTheme.primary;
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const Text("Safety Score", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Animated Donut Chart
            SizedBox(
              height: 220,
              width: 220,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: safetyScore),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: SafetyDonutPainter(
                          percentage: value,
                          color: statusColor,
                          backgroundColor: Colors.grey[200]!,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${(value * 100).toInt()}%",
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                          Text(
                            isScam ? "RISK" : "SAFE",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor.withOpacity(0.8), letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: statusColor.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(resultIcon, size: 60, color: statusColor),
                  ),
                  const SizedBox(height: 20),
                  Text(resultTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 8),
                  Text("Confidence: ${(confidence * 100).toInt()}%", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Details
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Why this result?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.manage_search, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(explanation, style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800])),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            // Bottom Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Scan Another Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chart Painter
class SafetyDonutPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  SafetyDonutPainter({required this.percentage, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 20.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SafetyDonutPainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.color != color;
}