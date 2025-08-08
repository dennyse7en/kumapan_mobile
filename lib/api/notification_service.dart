// lib/api/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Meminta izin dari pengguna (penting untuk iOS)
    await _fcm.requestPermission();

    // Mengambil token FCM unik untuk perangkat ini
    final fcmToken = await _fcm.getToken();
    print('FCM Token: $fcmToken');
  }
}
