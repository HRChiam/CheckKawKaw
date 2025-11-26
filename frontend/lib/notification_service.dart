import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'record_service.dart';

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
