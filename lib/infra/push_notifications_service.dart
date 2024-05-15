import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

enum PushNotificationPermission { granted, denied, unknown }

class PushNotificationsService {
  static const _channel = 'drimble';
  static const _permissionStatusKey = 'notifications';

  final FlutterLocalNotificationsPlugin _localNotificationsService;

  PushNotificationsService(this._localNotificationsService);

  Future<void> askForPermission() async {
    final granted = Platform.isAndroid
        ? await _localNotificationsService
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
            .requestNotificationsPermission()
        : await _localNotificationsService
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
            .requestPermissions(alert: true);

    if (granted != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(_permissionStatusKey, granted);
    }
  }

  Future<PushNotificationPermission> getPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final granted = prefs.getBool(_permissionStatusKey);

    if (granted == null) {
      return PushNotificationPermission.unknown;
    }

    return granted ? PushNotificationPermission.granted : PushNotificationPermission.denied;
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
