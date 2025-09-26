import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<String?> requestPermissionAndToken() async {
    await _fm.requestPermission();
    return _fm.getToken();
  }

  Stream<RemoteMessage> foregroundMessages() => FirebaseMessaging.onMessage;

  // Placeholder to trigger notifications via backend
  Future<void> triggerTestNotification(String toToken, String title, String body) async {
    // Implement via your server using FCM HTTPv1 API
  }
}
