import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';

// إنشاء instance منفصل للإشعارات في الخلفية
final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String taskName = 'reminderTask';
const String notificationTitle = 'تذكير';
const String notificationBody = 'لا تنسى ذكر الله';
const String lastActiveKey = 'last_active_time';
const int reminderHours = 3;

class InactivityReminderService {
  static final InactivityReminderService _instance =
      InactivityReminderService._internal();
  factory InactivityReminderService() => _instance;
  InactivityReminderService._internal();

  bool _initialized = false;
  DateTime? _lastActiveTime;
  Timer? _reminderTimer; // للاستخدام على Windows

  Future<void> initialize() async {
    if (_initialized) return;

    // تهيئة workmanager فقط على Android و iOS
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await Workmanager().initialize(callbackDispatcher);
      } catch (e) {
        debugPrint('خطأ في تهيئة workmanager: $e');
      }
    }
    _initialized = true;
  }

  Future<void> scheduleReminder() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // استخدام workmanager على الأنظمة المدعومة
      try {
        await Workmanager().registerOneOffTask(
          taskName,
          taskName,
          initialDelay: Duration(hours: reminderHours),
        );
      } catch (e) {
        debugPrint('خطأ في جدولة التذكير: $e');
      }
    } else if (Platform.isWindows) {
      // استخدام Timer على Windows
      _reminderTimer?.cancel();
      _reminderTimer = Timer(Duration(hours: reminderHours), () async {
        await _showReminderNotification();
      });
      debugPrint('✓ تم جدولة تذكير باستخدام Timer على Windows');
    }
  }

  Future<void> cancelReminder() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await Workmanager().cancelByUniqueName(taskName);
      } catch (e) {
        debugPrint('خطأ في إلغاء التذكير: $e');
      }
    } else if (Platform.isWindows) {
      _reminderTimer?.cancel();
      _reminderTimer = null;
      debugPrint('✓ تم إلغاء تذكير Timer على Windows');
    }
  }

  Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    _lastActiveTime = DateTime.now();
    await prefs.setInt(lastActiveKey, _lastActiveTime!.millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(lastActiveKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  void onAppBackgrounded() {
    updateLastActiveTime();
    scheduleReminder();
  }

  void onAppForegrounded() {
    cancelReminder();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      await _showReminderNotification();
    }
    return Future.value(true);
  });
}

Future<void> _showReminderNotification() async {
  // تهيئة الإشعارات في الخلفية
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await _backgroundNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'reminder_channel',
    'تذكير الأذكار',
    channelDescription: 'إشعارات تذكير بذكر الله',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
    playSound: true,
    enableVibration: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await _backgroundNotificationsPlugin.show(
    100,
    notificationTitle,
    notificationBody,
    notificationDetails,
  );
}
