import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification settings and permissions
  Future<void> initialize() async {
    // Request notification permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint("⚠️ Notification permission denied");
      return;
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    debugPrint("✅ Notification service initialized successfully");

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _updateTokenInFirestore(newToken);
    });
  }

  /// Get and update token in Firestore after login
  Future<void> updateFcmTokenAfterLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        debugPrint("⚠️ Failed to get FCM token");
        return;
      }else{
        log(fcmToken);
      }

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'fcmToken': fcmToken,
      });

      debugPrint("✅ FCM token updated successfully: $fcmToken");
    } catch (e) {
      debugPrint("❌ Error updating FCM token: $e");
    }
  }

  /// Show notification when message received in foreground
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // channel id
      'High Importance Notifications', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformDetails,
    );
  }

  /// Update token when refreshed
  Future<void> _updateTokenInFirestore(String newToken) async { 
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      'fcmToken': newToken,
    });

    debugPrint("🔁 Token refreshed and updated: $newToken");
  }
}
