import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:water_reminder/notification_services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();
  runApp(const WaterReminderApp());
}

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _customInterval = 5;
  bool _isReminderActive = false;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminder',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _notificationsPlugin.show(
      0,
      'Minum Air!',
      'Jangan lupa minum air sekarang.',
      details,
    );
  }

  Future<void> _scheduleRepeatingNotification() async {
    await _cancelNotification();

    await _notificationsPlugin.zonedSchedule(
      0,
      "Hydrated Your Body!",
      "Drink water right now! Keep your body hyrdrated.",
      tz.TZDateTime.now(tz.local).add(Duration(minutes: _customInterval)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'water_reminder_channel',
          'Water Reminder',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.periodicallyShow(
      0,
      'Minum Air!',
      'Jangan lupa minum air sekarang.',
      RepeatInterval.everyMinute, // Setiap 10 menit
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _cancelNotification() async {
    await _notificationsPlugin.cancelAll();
  }

  void _toggleReminder() {
    setState(() {
      _isReminderActive = !_isReminderActive;
    });
    if (_isReminderActive) {
      _scheduleRepeatingNotification();
    } else {
      _cancelNotification();
    }
  }

  void _startReminder() {
    setState(() {
      _isReminderActive = true;
    });
    _scheduleRepeatingNotification();
  }

  void _stopReminder() {
    setState(() {
      _isReminderActive = false;
    });
    _cancelNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(LucideIcons.droplet, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              'Stay Hydrated',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Keep you hydrated is our job!',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  DropdownButton<int>(
                    dropdownColor: Colors.grey[900],
                    value: _customInterval,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    items:
                        [1, 5, 10, 15]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  '$e minute',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _customInterval = value;
                        });
                        if (_isReminderActive) {
                          _scheduleRepeatingNotification();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _toggleReminder,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient:
                      _isReminderActive
                          ? const LinearGradient(
                            colors: [Colors.redAccent, Colors.deepOrange],
                          )
                          : const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                          ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _isReminderActive
                              ? Colors.redAccent
                              : Colors.blueAccent,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _isReminderActive ? 'Stop Reminder' : 'Start Reminder',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
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
