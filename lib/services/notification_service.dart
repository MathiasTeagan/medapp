import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._();

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      final androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'daily_reading_check',
            actions: [
              DarwinNotificationAction.plain('MARK_AS_READ', 'Okudum'),
              DarwinNotificationAction.plain('MARK_AS_NOT_READ', 'Okumadım'),
            ],
            options: {
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
      );

      final settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final granted = await _requestPermissions();
      if (!granted) {
        debugPrint('Bildirim izinleri reddedildi');
        return;
      }

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      debugPrint('Bildirim servisi başlatıldı');
    } catch (e) {
      debugPrint('Bildirim servisi başlatılırken hata oluştu: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
              provisional: true,
            );
        debugPrint('iOS bildirim izni sonucu: $result');
        return result ?? false;
      } else {
        final status = await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        debugPrint('Android bildirim izni sonucu: $status');
        return status ?? false;
      }
    } catch (e) {
      debugPrint('İzin isteme sırasında hata oluştu: $e');
      return false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlemler
  }

  Future<void> scheduleDailyReadingCheck() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reading_check',
      'Günlük Okuma Kontrolü',
      channelDescription: 'Günlük chapter okuma durumunu kontrol eder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      22, // Saat 22:00
      0,
    );

    if (now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1,
      'Günlük Okuma Kontrolü',
      'Bugün bir chapter okudun mu?',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleChapterReminder(
      String chapterName, DateTime plannedDate) async {
    const androidDetails = AndroidNotificationDetails(
      'chapter_reminder',
      'Chapter Hatırlatıcı',
      channelDescription: 'Planlanan chapterların okunma durumunu kontrol eder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = DateTime(
      plannedDate.year,
      plannedDate.month,
      plannedDate.day,
      22, // Saat 22:00
      0,
    );

    await _notifications.zonedSchedule(
      plannedDate.millisecondsSinceEpoch ~/ 1000,
      'Chapter Kontrolü',
      'Planını gerçekleştirip $chapterName chapterını okudun mu?',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Test için anlık bildirim gönderme
  Future<void> showTestDailyReadingNotification() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      debugPrint('Test bildirimi gönderiliyor...');

      const androidDetails = AndroidNotificationDetails(
        'daily_reading_check',
        'Günlük Okuma Kontrolü',
        channelDescription: 'Günlük chapter okuma durumunu kontrol eder',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        'Günlük Okuma Kontrolü',
        'Bugün bir chapter okudun mu?',
        details,
      );

      debugPrint('Test bildirimi gönderildi');
    } catch (e) {
      debugPrint('Bildirim gönderilirken hata oluştu: $e');
    }
  }

  Future<void> showTestChapterReminder(String chapterName) async {
    const androidDetails = AndroidNotificationDetails(
      'chapter_reminder',
      'Chapter Hatırlatıcı',
      channelDescription: 'Planlanan chapterların okunma durumunu kontrol eder',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Chapter Kontrolü',
      'Planını gerçekleştirip $chapterName chapterını okudun mu?',
      details,
    );
  }
}
