import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  FCMService._private();
  static final FCMService instance = FCMService._private();

  final _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // request permission
    await _fm.requestPermission();
    // local notifications init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: android);
    await _local.initialize(initSettings, onDidReceiveNotificationResponse: (payload) {});
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final n = msg.notification;
      if (n != null) showLocalNotification(n.title ?? 'Alert', n.body ?? '');
    });
  }

  Future<void> showLocalNotification(String title, String body) async {
    const android = AndroidNotificationDetails('alerts','Alerts',importance: Importance.max, priority: Priority.high);
    const notif = NotificationDetails(android: android);
    await _local.show(0, title, body, notif);
  }
}
