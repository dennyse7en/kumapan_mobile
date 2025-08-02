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

    // TODO: Kirim token ini ke server Laravel Anda untuk disimpan
    // di kolom 'fcm_token' pada tabel 'users'.
    // Buat endpoint API baru di Laravel untuk ini.
  }
}
