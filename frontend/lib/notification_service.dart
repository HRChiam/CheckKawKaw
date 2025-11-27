import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Function(String actionId)? onActionReceived;

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final actionId = details.actionId;
        if (actionId != null) {
          print("🔔 ACTION PRESSED → $actionId");
          onActionReceived?.call(actionId);
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'risk_alerts', // id
      'High Risk Alerts', // title
      description: 'Notifications for detected scams',
      importance: Importance.max, // Max importance for heads-up display
      playSound: true,
    );

    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future showUnknownCaller(String number) async {
    const androidDetails = AndroidNotificationDetails(
      'call_alert',
      'Call Alerts',
      channelDescription: 'Alerts for unknown callers',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Unknown Caller Detected',
      'Incoming call from $number',
      notificationDetails,
    );
  }

  static Future showCautionReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'caution_alert',
      'Safety Reminders',
      channelDescription: 'Reminders to stay safe during unknown calls',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.show(
      2,
      '⚠️ Stay Alert',
      'Unknown caller detected. Be careful of scams (OTP, bank requests, urgent threats).',
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future showPostCallCheck() async {
    const androidDetails = AndroidNotificationDetails(
      'post_call',
      'Post Call Safety Check',
      channelDescription: 'Safety check after the call ends',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.show(
      3,
      '📞 Call Ended – Safety Check',
      'Did the caller ask for your bank account, TAC/OTP, or personal info? Review now in CheckKawKaw.',
      const NotificationDetails(android: androidDetails),
    );
  }

}
