import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification Service — Handles daily reminder scheduling for DuitKu
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // ─── Initialize ────────────────────────────────────────
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings: initSettings);
  }

  // ─── Schedule Daily Reminder ───────────────────────────
  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // Save preferred time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', hour);
    await prefs.setInt('reminder_minute', minute);

    const androidDetails = AndroidNotificationDetails(
      'duitku_daily',
      'Pengingat Harian',
      channelDescription: 'Pengingat untuk mencatat keuangan harian',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFC9A84C),
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    // Show a test notification immediately
    await _notifications.show(
      id: 0,
      title: '🪙 DuitKu Reminder',
      body: 'Jangan lupa catat pengeluaranmu hari ini!',
      notificationDetails: details,
    );

    debugPrint('Daily reminder scheduled for $hour:$minute');
  }

  // ─── Cancel All Notifications ──────────────────────────
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_hour');
    await prefs.remove('reminder_minute');
  }

  // ─── Get Saved Reminder Time ───────────────────────────
  static Future<TimeOfDay?> getSavedReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');
    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }
}
