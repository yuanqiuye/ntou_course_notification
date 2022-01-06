import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';
import 'dart:convert';

extension DateTimeExtension on tz.TZDateTime {
  tz.TZDateTime next(int day) {
    return add(
      Duration(
        days: (day - weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}

Future<bool> cancelNotification(int id) async {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");
  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin.cancel(id);
  return false;
}

Future<String> setNotification(
    Map<String, dynamic>? data, int hr, int min) async {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");
  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));
  var time = tz.TZDateTime.now(tz.local);
  final tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, time.year,
          time.month, time.day, data!["time"].item1, data["time"].item2, 5)
      .subtract(
        Duration(hours: hr, minutes: min),
      )
      .next(data["weekday"]);
  print(scheduledDate);
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('channelId', 'channelName',
          channelDescription: 'channelDescription');
  await flutterLocalNotificationsPlugin.zonedSchedule(
      data["weekday"] * 20 + data["prior"],
      data["cName"] + "快要上課囉！",
      "時間: " +
          data["time"].item1.toString().padLeft(2, "0") +
          ":" +
          data["time"].item2.toString().padLeft(2, "0") +
          " 地點: " +
          data["loc"],
      scheduledDate,
      const NotificationDetails(android: androidNotificationDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  return scheduledDate.toIso8601String().substring(11, 16) +
      hr.toString().padLeft(2, "0") +
      min.toString().padLeft(2, "0");
}
