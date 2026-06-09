import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'revision_channel',
      'Revision Reminders',
      channelDescription: 'Reminders for upcoming topic revisions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    await _plugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          channelDescription: 'Daily study reminders',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

final notificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
