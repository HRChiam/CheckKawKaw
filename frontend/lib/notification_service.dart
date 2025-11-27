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
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'START_RECORD',
          'Yes, record',
        ),
        AndroidNotificationAction(
          'STOP_RECORD',
          'No',
        ),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Unknown Caller Detected',
      'Incoming call from $number',
      notificationDetails,
    );
  }

  static Future showHighRiskAlert(String cautionMessage) async {
    final androidDetails = AndroidNotificationDetails(
      'risk_alerts', // Must match the channel ID created above
      'High Risk Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      fullScreenIntent: true, // ✅ Helps force it to show over other apps
      styleInformation: BigTextStyleInformation(cautionMessage),
    );

    await _plugin.show(
      99,
      '⚠️ Scam Risk Detected',
      cautionMessage,
      NotificationDetails(android: androidDetails),
    );
  }
}
