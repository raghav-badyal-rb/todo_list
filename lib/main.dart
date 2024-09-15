import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models/task.dart'; // Adjust import based on your file structure
import 'screens/task_list_screen.dart'; // Adjust import based on your file structure
import 'screens/add_edit_task_screen.dart'; // Adjust import based on your file structure

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');
  tz.initializeTimeZones(); // Initialize time zones
  initializeNotifications();
  runApp(MyApp());
}

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null, // Add iOS settings if needed
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
      // Handle notification tap
      final payload = notificationResponse.payload;
      if (payload != null) {
        // Handle the payload or navigate to a specific screen
        print('Notification payload: $payload');
      }
    },
  );
}

Future<void> scheduleNotification(Task task) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'task_channel_id', // Channel ID
    'Task Notifications', // Channel Name
    //'Notifications for task reminders', // Channel Description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  final dueDate = tz.TZDateTime.from(task.dueDate, tz.local);
  final scheduledDate = dueDate.subtract(Duration(hours: 1));

  await flutterLocalNotificationsPlugin.zonedSchedule(
    task.key ?? 0, // Ensure this is a unique ID
    'Task Reminder', // Notification Title
    '${task.title} is due soon!', // Notification Body
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}
