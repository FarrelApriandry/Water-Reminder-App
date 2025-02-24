import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == "lagi") {
          scheduleReminder(10); // Ulangi reminder 10 menit lagi
        } else if (details.payload == "clear") {
          cancelReminder();
        }
      },
    );
  }

  static Future<void> scheduleReminder(int minutes) async {
    await _notifications.zonedSchedule(
      0,
      'Water Reminder',
      'Saatnya minum air! 💧',
      tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder',
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('lagi', 'Lagi'),
            AndroidNotificationAction('clear', 'Clear'),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelReminder() async {
    await _notifications.cancel(0);
  }
}
