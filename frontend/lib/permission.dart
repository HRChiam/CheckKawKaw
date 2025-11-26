import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homeScreen.dart';
import 'main.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  void initState() {
    super.initState();
    // _checkIfAlreadyGranted();
  }

  // Future _checkIfAlreadyGranted() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool grantedBefore = prefs.getBool("permissions_granted") ?? false;

  //   if (grantedBefore) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const HomeScreen()),
  //     );
  //   }
  // }

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
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Permissions & Privacy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "To detect scams accurately, CheckKawKaw needs the following permissions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Permission list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  PermissionItem(
                    icon: Icons.call_outlined,
                    title: "Phone Calls",
                    description:
                        "Detects incoming calls to trigger scam protection.",
                  ),
                  PermissionItem(
                    icon: Icons.mic_none_outlined,
                    title: "Microphone",
                    description:
                        "Allows scam voice analysis when recording is enabled.",
                  ),
                  PermissionItem(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    description:
                        "Shows alerts when suspicious calls are detected.",
                  ),
                ],
              ),
            ),

            // Footer button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final statuses = await [
                      Permission.phone,
                      Permission.microphone,
                      Permission.notification,
                    ].request();

                    print("📌 PHONE: ${statuses[Permission.phone]}");
                    print("📌 MIC: ${statuses[Permission.microphone]}");
                    print("📌 NOTIF: ${statuses[Permission.notification]}");

                    // permanently denied → open settings
                    if (statuses[Permission.phone]!.isPermanentlyDenied ||
                        statuses[Permission.microphone]!.isPermanentlyDenied ||
                        statuses[Permission.notification]!.isPermanentlyDenied) {
                      openAppSettings();
                      return;
                    }

                    bool allGranted =
                        statuses[Permission.phone]!.isGranted &&
                        statuses[Permission.microphone]!.isGranted &&
                        statuses[Permission.notification]!.isGranted;

                    if (allGranted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool("permissions_granted", true);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please allow all permissions to continue"),
                        ),
                      );
                    }
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
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.light,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.dark, size: 24),
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
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
