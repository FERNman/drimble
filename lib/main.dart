import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'drimble_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  final localTimezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimezone));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099, automaticHostMapping: false);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080, automaticHostMapping: false);
  }

  const initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_name');
  const initializationSettingsIOS = DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  await FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    ),
  );

  runApp(const DrimbleApp());
}
