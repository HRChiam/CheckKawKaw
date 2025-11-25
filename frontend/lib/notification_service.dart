import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  static Future showUnknownCaller(String number) async {
    const androidDetails = AndroidNotificationDetails(
      'unknown_call_channel',
      'Unknown Call Alerts',
      channelDescription: 'Notifies user when caller is not in contacts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Unknown Caller Detected',
      'Incoming call from $number',
      notificationDetails,
    );
  }

  static Future showHighRiskAlert() async {
    const androidDetails = AndroidNotificationDetails(
      'risk_alerts',
      'High Risk Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await _plugin.show(
      99,
      '⚠️ Scam Risk Detected',
      'This call may be dangerous. Stay alert.',
      NotificationDetails(android: androidDetails),
    );
  }
}
