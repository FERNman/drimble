import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class PushNotificationsService {
  static const _channel = 'drimble';

  final FlutterLocalNotificationsPlugin _localNotificationsService;

  PushNotificationsService(this._localNotificationsService);

  Future<void> askForPermission() async {
    if (Platform.isAndroid) {
      await _localNotificationsService
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    } else {
      await _localNotificationsService
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(alert: true);
    }
  }

  Future<void> scheduleNotification(
    int id, {
    required String title,
    required String description,
    required DateTime at,
  }) async {
    await _localNotificationsService.zonedSchedule(
      id,
      title,
      description,
      tz.TZDateTime.from(at, tz.local),
      _getDefaultNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails _getDefaultNotificationDetails() {
    // TODO: Localize
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channel,
        'Reminders',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    );
  }
}
