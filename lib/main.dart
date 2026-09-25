import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:prayer/quran/quran_home_screen.dart';
import 'package:prayer/quran/tafsir_screen.dart';
import 'package:prayer/quran/tafsir_api_service.dart';
import 'package:prayer/quran/quran_completion_screen.dart';
import 'azkar/azkar_screens.dart';
import 'services/inactivity_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String _kPrefAdhanEnabled = 'adhan_enabled';
const String _kPrefAdhanPrayerPrefix = 'adhan_prayer_';
const List<Map<String, String>> _kPrayerList = [
  {'name': 'Fajr', 'arabic': 'الفجر'},
  {'name': 'Dhuhr', 'arabic': 'الظهر'},
  {'name': 'Asr', 'arabic': 'العصر'},
  {'name': 'Maghrib', 'arabic': 'المغرب'},
  {'name': 'Isha', 'arabic': 'العشاء'},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة المناطق الزمنية مبكراً جداً لمنع LateInitializationError
  try {
    tzdata.initializeTimeZones();
    debugPrint('✓ تم تهيئة المناطق الزمنية بنجاح');
  } catch (e) {
    debugPrint('خطأ في تهيئة المناطق الزمنية: $e');
  }

  await initializeDateFormatting('ar_DZ');

  // تهيئة الإشعارات أولاً
  try {
    await _initializeNotifications();
    debugPrint('✓ تم تهيئة الإشعارات بنجاح');
  } catch (e) {
    debugPrint('خطأ في تهيئة الإشعارات: $e');
  }

  // تهيئة خدمة التذكير (تعمل على جميع الأنظمة الآن)
  try {
    await InactivityReminderService().initialize();
    debugPrint('✓ تم تهيئة خدمة التذكير بنجاح');
  } catch (e) {
    debugPrint('خطأ في تهيئة خدمة التذكير: $e');
  }

  Intl.defaultLocale = 'ar_DZ';
  runApp(const MyApp());
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _adhanEnabled = true;
  final Map<String, bool> _prayerEnabled = {
    for (var p in _kPrayerList) p['name']!: true,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    bool enabled = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      enabled = prefs.getBool(_kPrefAdhanEnabled) ?? true;
      for (var p in _kPrayerList) {
        final key = '$_kPrefAdhanPrayerPrefix${p['name']!.toLowerCase()}';
        _prayerEnabled[p['name']!] = prefs.getBool(key) ?? true;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _adhanEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool v) async {
    setState(() {
      _adhanEnabled = v;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefAdhanEnabled, v);
    } catch (_) {}
  }

  Future<void> _setPrayerEnabled(String name, bool v) async {
    setState(() {
      _prayerEnabled[name] = v;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kPrefAdhanPrayerPrefix${name.toLowerCase()}';
      await prefs.setBool(key, v);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSettingsSection(
                    title: 'تنبيهات الأذان',
                    children: [
                      Column(
                        children: [
                          _buildSwitchTile(
                            title: 'تفعيل صوت الأذان',
                            subtitle: 'تشغيل صوت الأذان عند دخول وقت الصلاة',
                            value: _adhanEnabled,
                            onChanged: _setEnabled,
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'الصلاة التي يُرفع فيها الأذان',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          for (var p in _kPrayerList)
                            _buildSwitchTile(
                              title: p['arabic']!,
                              subtitle: 'تشغيل الأذان عند ${p['arabic']!}',
                              value: _prayerEnabled[p['name']!] ?? true,
                              onChanged: (v) {
                                // allow editing even if master toggle is off; master controls actual playback
                                _setPrayerEnabled(p['name']!, v);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    title: 'حول التنبيهات',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'ملاحظة لمستخدمي Android',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'يعتمد تشغيل الأذان والتطبيق مغلق على قنوات الإشعارات. إذا قمت بتغيير إعدادات الصوت، قد تحتاج لإعادة تثبيت التطبيق لتفعيل القنوات الجديدة.',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

Future<void> _initializeNotifications() async {
  try {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // معالجة الضغط على الإشعار
        if (response.payload != null &&
            response.payload!.startsWith('adhan:')) {
          final prayerName = response.payload!.substring(6);
          // فتح شاشة الأذان
          _navigateToAdhanPlayer(prayerName);
        }
      },
    );
  } catch (e) {
    debugPrint('خطأ في تهيئة الإشعارات: $e');
    return;
  }

  // تهيئة قنوات الإشعارات للأنظمة المدعومة
  if (Platform.isAndroid) {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'prayer_channel',
            'Prayer Notifications',
            description: 'Notifications for prayer times',
            importance: Importance.max,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'prayer_channel_adhan',
            'Prayer Time Adhan',
            description: 'Adhan notifications at prayer time',
            importance: Importance.max,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'prayer_channel_adhan_sound',
            'Prayer Time Adhan (Sound)',
            description: 'Adhan notifications with custom sound',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan'),
            playSound: true,
          ),
        );
      } catch (e) {
        debugPrint('خطأ أثناء إنشاء قنوات الإشعارات على أندرويد: $e');
      }

      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('خطأ أثناء طلب إذن المنبهات الدقيقة: $e');
      }

      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (e) {
        debugPrint('خطأ أثناء طلب إذن الإشعارات: $e');
      }
    }
  }

  if (Platform.isIOS) {
    try {
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('خطأ أثناء طلب أذونات iOS: $e');
    }
  }
}

// متغير global لتخزين context التطبيق
BuildContext? _appContext;

void _navigateToAdhanPlayer(String prayerName) {
  if (_appContext != null) {
    Navigator.of(_appContext!).push(
      MaterialPageRoute(
        builder: (_) => AdhanPlayerScreen(prayerName: prayerName),
      ),
    );
  }
}

class _TasbihDailyPoint {
  final DateTime date;
  final int total;

  const _TasbihDailyPoint({required this.date, required this.total});
}

class TasbihStatsScreen extends StatefulWidget {
  const TasbihStatsScreen({super.key});

  @override
  State<TasbihStatsScreen> createState() => _TasbihStatsScreenState();
}

class _TasbihStatsScreenState extends State<TasbihStatsScreen> {
  bool _loading = true;
  List<_TasbihDailyPoint> _points = const [];
  int _days = 14;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final List<_TasbihDailyPoint> points = [];

      for (int i = _days - 1; i >= 0; i--) {
        final d = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(d);
        final key = 'tasbih_daily_$dateKey';
        final total = prefs.getInt(key) ?? 0;
        points.add(_TasbihDailyPoint(date: d, total: total));
      }

      if (!mounted) return;
      setState(() {
        _points = points;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _points = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = _points.any((p) => p.total > 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text(
          'إحصائيات الذكر',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'عرض الإحصائيات حسب الأيام',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7')),
                        ButtonSegment(value: 14, label: Text('14')),
                        ButtonSegment(value: 30, label: Text('30')),
                      ],
                      selected: {_days},
                      onSelectionChanged: (v) {
                        final days = v.isEmpty ? 14 : v.first;
                        setState(() {
                          _days = days;
                        });
                        _load();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : (!hasAny
                            ? const Center(
                                child: Text(
                                  'لا توجد بيانات بعد. ابدأ بالتسبيح وسيظهر الرسم البياني هنا.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY:
                                      (_points
                                          .map((e) => e.total)
                                          .fold<int>(0, (a, b) => a > b ? a : b)
                                          .toDouble()) +
                                      1,
                                  gridData: const FlGridData(show: true),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: const Color(0xFFE6E6E6),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 38,
                                        getTitlesWidget: (value, meta) {
                                          if (value % 5 != 0 &&
                                              value != meta.max) {
                                            return const SizedBox.shrink();
                                          }
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          final i = value.toInt();
                                          if (i < 0 || i >= _points.length) {
                                            return const SizedBox.shrink();
                                          }
                                          final d = _points[i].date;
                                          final label = DateFormat(
                                            'MM/dd',
                                          ).format(d);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(_points.length, (i) {
                                    final p = _points[i];
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: p.total.toDouble(),
                                          width: _points.length >= 25 ? 6 : 10,
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ألوان التطبيق
class AppColors {
  static const Color primary = Color(0xFF0D5C36);
  static const Color primaryDark = Color(0xFF084029);
  static const Color accent = Color(0xFFD4AF37); // ذهبي
  static const Color accentLight = Color(0xFFE8D5A3);
  static const Color surface = Color(0xFFF8F6F0);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C5C);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _checkedTafsirDownload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      InactivityReminderService().onAppBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      InactivityReminderService().onAppForegrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الأذكار وأوقات الصلاة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'DZ'),
      supportedLocales: const [Locale('ar', 'DZ'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Directionality(textDirection: TextDirection.rtl, child: child);
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          if (!_checkedTafsirDownload) {
            _checkedTafsirDownload = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndPromptTafsirDownload(context);
            });
          }
          return const HomeScreen();
        },
      ),
    );
  }

  Future<void> _checkAndPromptTafsirDownload(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted || !context.mounted) {
      return;
    }

    final alreadyPrompted = prefs.getBool('tafsir_muyassar_prompted') ?? false;
    final alreadyDownloaded =
        prefs.getBool('tafsir_muyassar_downloaded') ?? false;
    if (alreadyDownloaded) {
      return;
    }
    if (alreadyPrompted) {
      return;
    }

    final shouldDownload = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('تنزيل التفسير'),
          content: const Text(
            'للاستخدام بدون إنترنت، يمكن تنزيل تفسير الميسّر كاملاً (114 سورة) وحفظه على جهازك. هل تريد التنزيل الآن؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('تنزيل'),
            ),
          ],
        );
      },
    );

    await prefs.setBool('tafsir_muyassar_prompted', true);

    if (!mounted || !context.mounted) {
      return;
    }

    if (shouldDownload != true || !context.mounted) {
      return;
    }

    final service = TafsirApiService();
    int done = 0;
    const total = 114;
    bool started = false;
    bool downloadFailed = false;
    bool cancelRequested = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!started) {
              started = true;
              Future.microtask(() async {
                try {
                  if (await service.isAllDownloaded()) {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    return;
                  }

                  final completed = await service.downloadAllMuyassarSurahs(
                    onProgress: (d, t) {
                      if (!dialogContext.mounted) return;
                      setState(() {
                        done = d;
                      });
                    },
                    shouldCancel: () => cancelRequested,
                  );

                  if (completed) {
                    await prefs.setBool('tafsir_muyassar_downloaded', true);
                  }
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (_) {
                  if (!cancelRequested) {
                    downloadFailed = true;
                  }
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              });
            }

            final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
            return AlertDialog(
              title: const Text('جاري تنزيل التفسير...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text('$done / $total', textAlign: TextAlign.center),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cancelRequested = true;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('إلغاء'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;

    if (downloadFailed) {
      final retry = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('فشل تنزيل التفسير'),
            content: const Text(
              'تعذر تنزيل ملفات التفسير. تأكد من اتصال الإنترنت ثم أعد المحاولة.',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إغلاق'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          );
        },
      );

      if (retry == true) {
        await prefs.setBool('tafsir_muyassar_prompted', false);
        if (!mounted || !context.mounted) return;
        await _checkAndPromptTafsirDownload(context);
      }
    }
  }
}

/// الصفحة الرئيسية الرسمية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PrayerTime> _prayerTimes = [];
  String _locationName = '';
  bool _isLoading = true;
  Timer? _timer;
  final Set<int> _scheduledNotificationIds = {};
  final Set<String> _alertedAtPrayerTime = {};
  bool _adhanEnabled = true;
  final Map<String, bool> _adhanPrayerEnabled = {
    for (var p in _kPrayerList) p['name']!: true,
  };

  @override
  void initState() {
    super.initState();
    _loadAdhanSetting();
    _loadPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _checkPrayerTimeTrigger();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdhanSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_kPrefAdhanEnabled) ?? true;
      for (var p in _kPrayerList) {
        final key = '$_kPrefAdhanPrayerPrefix${p['name']!.toLowerCase()}';
        _adhanPrayerEnabled[p['name']!] = prefs.getBool(key) ?? true;
      }
      if (!mounted) return;
      setState(() {
        _adhanEnabled = enabled;
      });
    } catch (_) {}
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('last_latitude');
      final savedLon = prefs.getDouble('last_longitude');
      final savedLocationName = prefs.getString('last_location_name');

      if (savedLat != null && savedLon != null) {
        // استخدام الإحداثيات المحفوظة فوراً
        _locationName = savedLocationName ?? 'موقعك المحفوظ';
        final times = await PrayerTimesCalculator.getPrayerTimesForLocation(
          savedLat,
          savedLon,
        );
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });

        // جدولة الإشعارات
        try {
          await _clearScheduledNotifications();
          await _schedulePrayerNotifications();
        } catch (e) {
          debugPrint('خطأ في جدولة إشعارات الصلاة من الصفحة الرئيسية: $e');
        }

        // لا داعي لطلب الموقع كل مرة إذا كان لدينا إحداثيات محفوظة
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position? position;

        // محاولة الحصول على الموقع الحالي أولاً
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          );
        } catch (e) {
          debugPrint('GPS مغلق أو غير متاح، جاري محاولة الحصول على آخر موقع');
          // إذا فشل GPS، حاول الحصول على آخر موقع معروف
          position = await Geolocator.getLastKnownPosition();
        }

        // إذا لم نحصل على الموقع الحالي ولا الأخير
        if (position == null) {
          setState(() {
            _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
            _locationName = '';
            _isLoading = false;
          });
          return;
        }

        // حفظ الإحداثيات الجديدة
        await prefs.setDouble('last_latitude', position.latitude);
        await prefs.setDouble('last_longitude', position.longitude);

        // الحصول على اسم الموقع وحفظه
        String locationName = 'موقعك الحالي';
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            List<String> locationParts = [];
            if (place.locality != null && place.locality!.isNotEmpty) {
              locationParts.add(place.locality!);
            }
            if (place.country != null && place.country!.isNotEmpty) {
              locationParts.add(place.country!);
            }
            locationName = locationParts.isNotEmpty
                ? locationParts.join(', ')
                : 'موقعك الحالي';
          }
        } catch (_) {}
        _locationName = locationName;
        await prefs.setString('last_location_name', locationName);

        // حساب أوقات الصلاة
        final times = await PrayerTimesCalculator.getPrayerTimesForLocation(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });

        try {
          await _clearScheduledNotifications();
          await _schedulePrayerNotifications();
        } catch (e) {
          debugPrint('خطأ في جدولة إشعارات الصلاة من الصفحة الرئيسية: $e');
        }
      } else {
        setState(() {
          _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
          _locationName = '';
          _isLoading = false;
        });

        try {
          await _clearScheduledNotifications();
          await _schedulePrayerNotifications();
        } catch (e) {
          debugPrint('خطأ في جدولة إشعارات الصلاة من الصفحة الرئيسية: $e');
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل أوقات الصلاة: $e');
      setState(() {
        _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
        _locationName = '';
        _isLoading = false;
      });

      try {
        await _clearScheduledNotifications();
        await _schedulePrayerNotifications();
      } catch (e) {
        debugPrint('خطأ في جدولة إشعارات الصلاة من الصفحة الرئيسية: $e');
      }
    }
  }

  Future<void> _clearScheduledNotifications() async {
    try {
      for (final id in _scheduledNotificationIds) {
        await flutterLocalNotificationsPlugin.cancel(id);
      }
      _scheduledNotificationIds.clear();
    } catch (e) {
      debugPrint('خطأ في مسح الإشعارات المجدولة: $e');
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_prayerTimes.isEmpty) return;

    // الإشعارات المجدولة مدعومة فقط على أندرويد و iOS حالياً
    if (!(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('⚠ الإشعارات المجدولة غير مدعومة على هذه المنصة');
      return;
    }

    try {
      final localTz = tz.local;
      final nowLocal = DateTime.now();
      final nowTz = tz.TZDateTime.from(nowLocal, localTz);

      const NotificationDetails beforeDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          ticker: 'تنبيه الصلاة',
          styleInformation: DefaultStyleInformation(true, true),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      int idBase = 1000;
      int idBaseAtTime = 2000;

      for (int i = 0; i < _prayerTimes.length; i++) {
        final p = _prayerTimes[i];
        if (p.name == 'Sunrise') continue;

        var scheduledBefore = tz.TZDateTime(
          localTz,
          nowLocal.year,
          nowLocal.month,
          nowLocal.day,
          p.time.hour,
          p.time.minute,
        ).subtract(const Duration(minutes: 2));
        if (scheduledBefore.isBefore(nowTz)) {
          scheduledBefore = scheduledBefore.add(const Duration(days: 1));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          idBase + i,
          '🕌 تنبيه الصلاة',
          'حان وقت ${p.arabicName} بعد دقيقتين',
          scheduledBefore,
          beforeDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'prayer_reminder_${p.name}',
        );
        _scheduledNotificationIds.add(idBase + i);

        if (!_adhanEnabled) {
          continue;
        }

        // تحقق من تفعيل الأذان لهذه الصلاة
        final prayerAllowed = _adhanPrayerEnabled[p.name] ?? true;
        if (!prayerAllowed) {
          continue;
        }

        var scheduledAtTime = tz.TZDateTime(
          localTz,
          nowLocal.year,
          nowLocal.month,
          nowLocal.day,
          p.time.hour,
          p.time.minute,
        );
        if (scheduledAtTime.isBefore(nowTz)) {
          scheduledAtTime = scheduledAtTime.add(const Duration(days: 1));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          idBaseAtTime + i,
          '🕌 حان وقت الصلاة',
          'حان الآن وقت صلاة ${p.arabicName}',
          scheduledAtTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_channel_adhan_sound_adhan',
              'Prayer Time Adhan (Sound)',
              channelDescription: 'Adhan notifications at prayer time',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              sound: const RawResourceAndroidNotificationSound('adhan'),
              enableVibration: true,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              visibility: NotificationVisibility.public,
              ticker: 'حان وقت الصلاة',
              styleInformation: const DefaultStyleInformation(true, true),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'adhan:${p.arabicName}',
        );
        _scheduledNotificationIds.add(idBaseAtTime + i);
      }
    } catch (e) {
      debugPrint('خطأ في جدولة الإشعارات: $e');
    }
  }

  void _checkPrayerTimeTrigger() {
    if (!_adhanEnabled) return;
    if (_prayerTimes.isEmpty) return;
    final now = DateTime.now();
    for (final p in _prayerTimes) {
      if (p.name == 'Sunrise') continue;
      if (p.time.hour == now.hour && p.time.minute == now.minute) {
        if (_alertedAtPrayerTime.contains(p.arabicName)) continue;
        final prayerAllowed = _adhanPrayerEnabled[p.name] ?? true;
        if (!prayerAllowed) continue;
        _alertedAtPrayerTime.add(p.arabicName);
        _navigateToAdhanPlayer(p.arabicName);
      }
    }

    if (now.hour == 0 && now.minute == 0 && now.second == 0) {
      _alertedAtPrayerTime.clear();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 17) return 'طاب يومك';
    if (hour >= 17 && hour < 20) return 'مساء الخير';
    return 'ليلة سعيدة';
  }

  String _getArabicHijriDate(HijriCalendar hijri) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    final monthName = months[hijri.hMonth - 1];
    return '${hijri.hDay} $monthName ${hijri.hYear} هـ';
  }

  @override
  Widget build(BuildContext context) {
    // تعيين الـ context العالمي للتنقل من الإشعارات
    _appContext = context;
    final now = DateTime.now();
    final hijriDate = HijriCalendar.now();
    final nextPrayer = PrayerTimesCalculator.getNextPrayer(
      _prayerTimes,
      now: now,
    );
    final timeUntilNext = nextPrayer != null
        ? PrayerTimesCalculator.getTimeUntilPrayer(nextPrayer.time, now: now)
        : const Duration();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Top spacing
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          // Header with greeting and date
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -40,
                    left: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Greeting
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Gregorian date
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'ar_DZ').format(now),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Separator line
                        Container(
                          width: 40,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Hijri date
                        Text(
                          _getArabicHijriDate(hijriDate),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: _isLoading
                  ? _buildLoadingCard()
                  : (nextPrayer != null
                        ? _buildNextPrayerCard(nextPrayer, timeUntilNext)
                        : const SizedBox.shrink()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                _FeatureGridItem(
                  title: 'أوقات الصلاة',
                  icon: Icons.access_time_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrayerTimesScreen(),
                      ),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'القرآن الكريم',
                  icon: Icons.book_rounded,
                  color: const Color(0xFFB71C1C),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuranHomeScreen(),
                      ),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'الأذكار',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF6A1B9A),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AzkarHomeScreen(),
                      ),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'التسبيح',
                  icon: Icons.brightness_low_rounded,
                  color: const Color(0xFF00695C),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasbihScreen()),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'تفسير القرآن',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF1A237E),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TafsirScreen()),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'ختم القرآن',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFFB71C1C),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuranCompletionScreen(),
                      ),
                    );
                  },
                ),
                _FeatureGridItem(
                  title: 'الإعدادات',
                  icon: Icons.settings_rounded,
                  color: const Color(0xFF455A64),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        )
                        .then((_) async {
                          try {
                            await _loadAdhanSetting();
                            await _clearScheduledNotifications();
                            await _schedulePrayerNotifications();
                          } catch (e) {
                            debugPrint(
                              'خطأ في تحديث إعدادات الأذان بعد الرجوع من الإعدادات: $e',
                            );
                          }
                        });
                  },
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF1B5E3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(PrayerTime nextPrayer, Duration timeUntilNext) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF1B5E3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    nextPrayer.icon,
                    color: AppColors.accentLight,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصلاة القادمة',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        nextPrayer.arabicName,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    PrayerTimesCalculator.formatTimeOfDay(nextPrayer.time),
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${timeUntilNext.inHours.toString().padLeft(2, '0')}:${(timeUntilNext.inMinutes % 60).toString().padLeft(2, '0')}:${(timeUntilNext.inSeconds % 60).toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                color: AppColors.accentLight,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            if (_locationName.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _locationName,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGridItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureGridItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FeatureGridItem> createState() => _FeatureGridItemState();
}

class _FeatureGridItemState extends State<_FeatureGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Decorative background element
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon container with gradient background
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withValues(alpha: 0.15),
                                widget.color.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.12),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Title text with better typography
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Decorative underline
                        Container(
                          width: 32,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrayerTime {
  final String name;
  final String arabicName;
  final TimeOfDay time;
  final IconData icon;

  PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.icon,
  });
}

/// شاشة تسبيح بسيطة
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _target = 33;
  int _phraseIndex = 0;
  bool _loading = true;
  final List<String> _phrases = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ',
  ];

  @override
  void initState() {
    super.initState();
    _loadTasbih();
  }

  Future<void> _loadTasbih() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phraseIndex = prefs.getInt('tasbih_phrase') ?? 0;
      _count = prefs.getInt('tasbih_count') ?? 0;
      _target = prefs.getInt('tasbih_target') ?? 33;
      _loading = false;
    });
  }

  Future<void> _saveTasbih() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_phrase', _phraseIndex);
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_target', _target);
  }

  Future<void> _incrementDailyTotal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = 'tasbih_daily_$dateKey';
      final current = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, current + 1);
    } catch (_) {}
  }

  void _increment() {
    HapticFeedback.selectionClick();
    setState(() {
      _count++;
    });
    _saveTasbih();
    _incrementDailyTotal();
  }

  void _decrement() {
    if (_count == 0) return;
    setState(() {
      _count--;
    });
    _saveTasbih();
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
    _saveTasbih();
  }

  void _setTarget(int t) {
    setState(() {
      _target = t;
      if (_count > _target) _count = _target;
    });
    _saveTasbih();
  }

  Future<void> _setCustomTarget() async {
    final controller = TextEditingController(text: _target.toString());
    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حدد الهدف'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final n = int.tryParse(controller.text.trim());
                if (n != null && n > 0) {
                  Navigator.of(context).pop(n);
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
    if (value != null) _setTarget(value);
  }

  void _setPhrase(int i) {
    setState(() {
      _phraseIndex = i;
      _count = 0;
    });
    _saveTasbih();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final progress = _target <= 0 ? 0.0 : (_count / _target).clamp(0.0, 1.0);
    final isComplete = _count >= _target;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8), // لون بيج دافئ كورق المصحف
      appBar: AppBar(
        title: const Text(
          'التسبيح',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'إحصائيات الذكر',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TasbihStatsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الذكر المختار
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_phrases.length, (i) {
                      final selected = _phraseIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(
                            _phrases[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: const Color(0xFFF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (_) => _setPhrase(i),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // الهدف
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('33', style: TextStyle(fontSize: 13)),
                      selected: _target == 33,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (_) => _setTarget(33),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('100', style: TextStyle(fontSize: 13)),
                      selected: _target == 100,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (_) => _setTarget(100),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _setCustomTarget,
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('مخصص', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_count / $_target',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // العداد الدائري
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // الدائرة الخارجية
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),

                        // مؤشر التقدم
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: const Color(0xFFE8E8E8),
                            color: isComplete
                                ? const Color(0xFF4CAF50)
                                : AppColors.primary,
                          ),
                        ),

                        // الدائرة الداخلية
                        Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),

                        // الأرقام والنص
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_count',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: isComplete
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _phrases[_phraseIndex],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // أزرار التحكم
              Row(
                children: [
                  // زر التصغير
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton.filledTonal(
                      onPressed: _decrement,
                      icon: const Icon(Icons.remove_rounded, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // زر التسبيح الرئيسي
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      onPressed: _increment,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.touch_app_rounded, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'تسبيح',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // زر التصفير
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton.filledTonal(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: const Color(0xFFE74C3C),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTimesCalculator {
  // دالة للحصول على اسم المنطقة الزمنية من الإحداثيات
  // الحل الأساسي: استخدام المنطقة الزمنية المحلية للجهاز
  // (يمكن تحسينها لاحقاً بخدمة geocoding لاحقة)
  static String getTimeZoneNameFromCoordinates(
    double latitude,
    double longitude,
  ) {
    // بدلاً من حساب تقريبي خاطئ، استخدم المنطقة المحلية
    // التطبيق الحقيقي يحتاج لخدمة Google Time Zone API
    return 'UTC'; // fallback آمن
  }

  // Calculate prayer times based on coordinates
  static Future<List<PrayerTime>> getPrayerTimesForLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      tzdata.initializeTimeZones();
      final coordinates = Coordinates(latitude, longitude);

      // استخدام طريقة حساب رابطة العالم الإسلامي كإعداد افتراضي دقيق
      final params = CalculationMethod.muslim_world_league.getParameters();

      // تحسين الدقة: استخدام المذهب الشافعي (الجمهور) كافتراضي،
      // ويمكن تغييره للحنفي إذا لزم الأمر في الإعدادات لاحقاً
      params.madhab = Madhab.shafi;

      final now = DateTime.now();
      final dateComponents = DateComponents(now.year, now.month, now.day);

      // استخدام إزاحة التوقيت المحلي بدقة
      final localOffset = now.timeZoneOffset;
      final prayerTimes = PrayerTimes.utcOffset(
        coordinates,
        dateComponents,
        params,
        localOffset,
      );

      return [
        PrayerTime(
          name: 'Fajr',
          arabicName: 'الفجر',
          time: TimeOfDay(
            hour: prayerTimes.fajr.hour,
            minute: prayerTimes.fajr.minute,
          ),
          icon: Icons.light_mode,
        ),
        PrayerTime(
          name: 'Sunrise',
          arabicName: 'الشروق',
          time: TimeOfDay(
            hour: prayerTimes.sunrise.hour,
            minute: prayerTimes.sunrise.minute,
          ),
          icon: Icons.wb_sunny,
        ),
        PrayerTime(
          name: 'Dhuhr',
          arabicName: 'الظهر',
          time: TimeOfDay(
            hour: prayerTimes.dhuhr.hour,
            minute: prayerTimes.dhuhr.minute,
          ),
          icon: Icons.sunny,
        ),
        PrayerTime(
          name: 'Asr',
          arabicName: 'العصر',
          time: TimeOfDay(
            hour: prayerTimes.asr.hour,
            minute: prayerTimes.asr.minute,
          ),
          icon: Icons.wb_twilight,
        ),
        PrayerTime(
          name: 'Maghrib',
          arabicName: 'المغرب',
          time: TimeOfDay(
            hour: prayerTimes.maghrib.hour,
            minute: prayerTimes.maghrib.minute,
          ),
          icon: Icons.brightness_6,
        ),
        PrayerTime(
          name: 'Isha',
          arabicName: 'العشاء',
          time: TimeOfDay(
            hour: prayerTimes.isha.hour,
            minute: prayerTimes.isha.minute,
          ),
          icon: Icons.nights_stay,
        ),
      ];
    } catch (e) {
      debugPrint('خطأ في حساب أوقات الصلاة: $e');
      // Return default prayer times if calculation fails
      return getDefaultPrayerTimes();
    }
  }

  static List<PrayerTime> getDefaultPrayerTimes() {
    return [
      PrayerTime(
        name: 'Fajr',
        arabicName: 'الفجر',
        time: const TimeOfDay(hour: 5, minute: 30),
        icon: Icons.light_mode,
      ),
      PrayerTime(
        name: 'Sunrise',
        arabicName: 'الشروق',
        time: const TimeOfDay(hour: 7, minute: 0),
        icon: Icons.wb_sunny,
      ),
      PrayerTime(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        time: const TimeOfDay(hour: 12, minute: 15),
        icon: Icons.sunny,
      ),
      PrayerTime(
        name: 'Asr',
        arabicName: 'العصر',
        time: const TimeOfDay(hour: 15, minute: 45),
        icon: Icons.wb_twilight,
      ),
      PrayerTime(
        name: 'Maghrib',
        arabicName: 'المغرب',
        time: const TimeOfDay(hour: 18, minute: 20),
        icon: Icons.brightness_6,
      ),
      PrayerTime(
        name: 'Isha',
        arabicName: 'العشاء',
        time: const TimeOfDay(hour: 19, minute: 50),
        icon: Icons.nights_stay,
      ),
    ];
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static Duration getTimeUntilPrayer(TimeOfDay prayerTime, {DateTime? now}) {
    now ??= DateTime.now();
    // احسب الفرق بالثواني (وليس بالدقائق فقط) حتى يتغير العدّاد كل ثانية.
    // ملاحظة: TimeOfDay لا يحتوي على ثواني، لكن difference سيعطي ثواني متبقية
    // إلى بداية دقيقة الصلاة القادمة.
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      prayerTime.hour,
      prayerTime.minute,
    );

    final nextOccurrence = target.isAfter(now)
        ? target
        : target.add(const Duration(days: 1));
    return nextOccurrence.difference(now);
  }

  static PrayerTime? getNextPrayer(List<PrayerTime> prayers, {DateTime? now}) {
    now ??= DateTime.now();
    final nowInMinutes = now.hour * 60 + now.minute;

    // ابحث عن أول صلاة لم تأتِ بعد
    for (var prayer in prayers) {
      final prayerInMinutes = prayer.time.hour * 60 + prayer.time.minute;
      if (prayerInMinutes > nowInMinutes) {
        return prayer;
      }
    }

    // إذا تجاوزنا كل الصلوات اليوم، أول صلاة غداً
    return prayers.isNotEmpty ? prayers.first : null;
  }
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  String _getArabicHijriDate(HijriCalendar hijri) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    final monthName = months[hijri.hMonth - 1];
    return '${hijri.hDay} $monthName ${hijri.hYear} هـ';
  }

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late Timer _timer;
  late List<PrayerTime> _prayerTimes;
  String _locationName = 'جاري تحديد الموقع...';
  bool _isLoading = true;
  final Set<String> _notifiedPrayers = {};
  final Set<String> _alertedAtPrayerTime = {};
  final Set<int> _scheduledNotificationIds = {};

  @override
  void initState() {
    super.initState();
    _prayerTimes = [];
    // تهيئة المناطق الزمنية للجدولة
    tzdata.initializeTimeZones();
    _requestLocationPermission();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkPrayerNotifications();
      setState(() {});
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('last_latitude');
      final savedLon = prefs.getDouble('last_longitude');
      final savedLocationName = prefs.getString('last_location_name');

      if (savedLat != null && savedLon != null) {
        _locationName = savedLocationName ?? 'موقعك المحفوظ';
        _getPrayerTimesForLocation(savedLat, savedLon);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _getLocation();
      } else {
        setState(() {
          _isLoading = false;
          _locationName = 'تم رفض إذن الموقع';
          _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
        });
      }
    } catch (e) {
      debugPrint('خطأ في طلب الإذن: $e');
      setState(() {
        _isLoading = false;
        _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_latitude', position.latitude);
      await prefs.setDouble('last_longitude', position.longitude);

      // تهيئة المناطق الزمنية (مطلوبة للجدولة)
      tzdata.initializeTimeZones();

      // Get location name from coordinates
      _getLocationName(position.latitude, position.longitude);

      // Get prayer times for this location
      _getPrayerTimesForLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('خطأ في الحصول على الموقع: $e');
      setState(() {
        _isLoading = false;
        _locationName = 'خطأ في الحصول على الموقع';
        _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
      });
    }
  }

  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      debugPrint(
        'جاري محاولة الحصول على اسم الموقع من الإحداثيات: ($latitude, $longitude)',
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      String locationName = 'موقع جديد';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> locationParts = [];

        // إضافة المدينة (locality)
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationParts.add(place.locality!);
        }

        // إضافة المحافظة/المنطقة إذا كانت مختلفة عن المدينة
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty &&
            place.administrativeArea != place.locality) {
          locationParts.add(place.administrativeArea!);
        }

        // إضافة الدولة
        if (place.country != null && place.country!.isNotEmpty) {
          locationParts.add(place.country!);
        }

        locationName = locationParts.isNotEmpty
            ? locationParts.join(', ')
            : 'موقع غير معروف';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_location_name', locationName);

      debugPrint('تم الحصول على اسم الموقع بنجاح: $locationName');
      setState(() {
        _locationName = locationName;
      });
    } catch (e) {
      debugPrint('خطأ في الحصول على اسم الموقع: $e');
      setState(() {
        _locationName = 'موقع جديد';
      });
    }
  }

  Future<void> _getPrayerTimesForLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final times = await PrayerTimesCalculator.getPrayerTimesForLocation(
        latitude,
        longitude,
      );
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });

      // بعد الحصول على أوقات الصلاة، قم بجدولة الإشعارات بناءً على المنطقة الزمنية
      try {
        await _clearScheduledNotifications();
        await _schedulePrayerNotifications();
      } catch (e) {
        debugPrint('خطأ في جدولة الإشعارات: $e');
      }
    } catch (e) {
      debugPrint('خطأ في حساب أوقات الصلاة: $e');
      setState(() {
        _isLoading = false;
        _prayerTimes = PrayerTimesCalculator.getDefaultPrayerTimes();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkPrayerNotifications() {
    try {
      final now = DateTime.now();
      final nowInMinutes = now.hour * 60 + now.minute;

      for (var prayer in _prayerTimes) {
        if (prayer.name == 'Sunrise') continue;

        final prayerInMinutes = prayer.time.hour * 60 + prayer.time.minute;
        final diffInMinutes = prayerInMinutes - nowInMinutes;

        // تنبيه عند وقت الصلاة (نفس الدقيقة)
        if (diffInMinutes == 0) {
          if (!_alertedAtPrayerTime.contains(prayer.arabicName)) {
            _alertedAtPrayerTime.add(prayer.arabicName);
            _sendNotificationAtPrayerTime(prayer);
            if (mounted) _showPrayerTimeDialog(prayer);
          }
        }

        // تنبيه قبل الصلاة بدقيقتين
        if (diffInMinutes <= 2 && diffInMinutes >= 0) {
          if (!_notifiedPrayers.contains(prayer.arabicName)) {
            _sendNotification(prayer);
            _notifiedPrayers.add(prayer.arabicName);
          }
        }
      }

      if (now.hour == 0 && now.minute == 0) {
        _notifiedPrayers.clear();
        _alertedAtPrayerTime.clear();
      }
    } catch (e) {
      debugPrint('خطأ في فحص الإشعارات: $e');
    }
  }

  void _showPrayerTimeDialog(PrayerTime prayer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.mosque, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            const Text('حان وقت الصلاة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حان الآن وقت صلاة ${prayer.arabicName}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              PrayerTimesCalculator.formatTimeOfDay(prayer.time),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تذكير لاحقاً'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotificationAtPrayerTime(PrayerTime prayer) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          ticker: 'حان وقت الصلاة',
          styleInformation: DefaultStyleInformation(true, true),
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      prayer.hashCode + 5000,
      '🕌 حان وقت الصلاة',
      'حان الآن وقت صلاة ${prayer.arabicName}',
      details,
      payload: 'adhan:${prayer.arabicName}',
    );
  }

  Future<void> _sendNotification(PrayerTime prayer) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          ticker: 'تنبيه الصلاة',
          styleInformation: DefaultStyleInformation(true, true),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      prayer.hashCode,
      '🕌 تنبيه الصلاة',
      'حان وقت ${prayer.arabicName} بعد دقيقتين',
      platformChannelSpecifics,
      payload: 'prayer_reminder_${prayer.name}',
    );
  }

  Future<void> _clearScheduledNotifications() async {
    try {
      for (var id in _scheduledNotificationIds) {
        await flutterLocalNotificationsPlugin.cancel(id);
      }
      _scheduledNotificationIds.clear();
    } catch (e) {
      debugPrint('خطأ في مسح الإشعارات المجدولة: $e');
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_prayerTimes.isEmpty) {
      debugPrint('لا توجد أوقات صلاة متاحة للجدولة');
      return;
    }
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Notifications',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // استخدام التوقيت المحلي للجهاز لجدولة الإشعارات
      final nowLocal = DateTime.now();
      tzdata.initializeTimeZones();
      final localTz = tz.local;
      final nowTz = tz.TZDateTime.from(nowLocal, localTz);
      debugPrint('جاري جدولة الإشعارات. الوقت الحالي: $nowTz');
      int idBase = 1000;
      int idBaseAtTime = 2000;
      for (int i = 0; i < _prayerTimes.length; i++) {
        final p = _prayerTimes[i];
        if (p.name == 'Sunrise') continue;

        // تنبيه قبل الصلاة بدقيقتين
        var scheduledBefore = tz.TZDateTime(
          localTz,
          nowLocal.year,
          nowLocal.month,
          nowLocal.day,
          p.time.hour,
          p.time.minute,
        ).subtract(const Duration(minutes: 2));
        if (scheduledBefore.isBefore(nowTz)) {
          scheduledBefore = scheduledBefore.add(const Duration(days: 1));
        }
        await flutterLocalNotificationsPlugin.zonedSchedule(
          idBase + i,
          '🕌 تنبيه الصلاة',
          'حان وقت ${p.arabicName} بعد دقيقتين',
          scheduledBefore,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        _scheduledNotificationIds.add(idBase + i);

        // تنبيه عند وقت الصلاة بالضبط مع fullScreenIntent
        var scheduledAtTime = tz.TZDateTime(
          localTz,
          nowLocal.year,
          nowLocal.month,
          nowLocal.day,
          p.time.hour,
          p.time.minute,
        );
        if (scheduledAtTime.isBefore(nowTz)) {
          scheduledAtTime = scheduledAtTime.add(const Duration(days: 1));
        }
        await flutterLocalNotificationsPlugin.zonedSchedule(
          idBaseAtTime + i,
          '🕌 حان وقت الصلاة',
          'حان الآن وقت صلاة ${p.arabicName}',
          scheduledAtTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_channel_adhan',
              'Prayer Time Adhan',
              channelDescription: 'Adhan notifications at prayer time',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              visibility: NotificationVisibility.public,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'adhan:${p.arabicName}',
        );
        _scheduledNotificationIds.add(idBaseAtTime + i);
      }
      debugPrint('تمت جدولة ${_scheduledNotificationIds.length} إشعارات بنجاح');
    } catch (e) {
      debugPrint('خطأ في جدولة الإشعارات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام DateTime.now() للحصول على الوقت المحلي الصحيح للجهاز
    final now = DateTime.now();
    final hijriDate = HijriCalendar.now();
    final dateFormatter = DateFormat('EEEE، d MMMM y', 'ar_DZ');

    final nextPrayer = PrayerTimesCalculator.getNextPrayer(
      _prayerTimes,
      now: now,
    );
    final timeUntilNext = nextPrayer != null
        ? PrayerTimesCalculator.getTimeUntilPrayer(nextPrayer.time, now: now)
        : const Duration();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    _locationName,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'أوقات الصلاة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: 60,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _locationName,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormatter.format(now),
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  widget._getArabicHijriDate(hijriDate),
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // بطاقة الصلاة القادمة المحسنة
                        if (nextPrayer != null)
                          _buildModernNextPrayerCard(nextPrayer, timeUntilNext),
                        const SizedBox(height: 24),
                        // مؤشر تقدم اليوم
                        _buildDayProgressIndicator(now),
                        const SizedBox(height: 32),
                        // عنوان القائمة
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'مواقيت اليوم',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final prayer = _prayerTimes[index];
                      if (prayer.name == 'Sunrise') {
                        return _buildSunriseCard(prayer);
                      }
                      final isNext =
                          nextPrayer != null &&
                          prayer.arabicName == nextPrayer.arabicName;

                      // تحديد ما إذا كانت الصلاة قد فاتت
                      final nowInMinutes = now.hour * 60 + now.minute;
                      final prayerInMinutes =
                          prayer.time.hour * 60 + prayer.time.minute;
                      final isPassed = prayerInMinutes < nowInMinutes;

                      return ModernPrayerTimeCard(
                        prayer: prayer,
                        isNext: isNext,
                        isPassed: isPassed,
                      );
                    }, childCount: _prayerTimes.length),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: _SpiritualQuoteCard(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _getLocation,
        icon: const Icon(Icons.my_location_rounded),
        label: Text('تحديث الموقع', style: GoogleFonts.cairo()),
        tooltip: 'تحديث الموقع وأوقات الصلاة',
      ),
    );
  }

  Widget _buildModernNextPrayerCard(
    PrayerTime nextPrayer,
    Duration timeUntilNext,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1B5E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nextPrayer.arabicName,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  nextPrayer.icon,
                  size: 32,
                  color: AppColors.accentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(
                  timeUntilNext.inHours.toString().padLeft(2, '0'),
                  'ساعة',
                ),
                _buildTimeSeparator(),
                _buildTimeUnit(
                  (timeUntilNext.inMinutes % 60).toString().padLeft(2, '0'),
                  'دقيقة',
                ),
                _buildTimeSeparator(),
                _buildTimeUnit(
                  (timeUntilNext.inSeconds % 60).toString().padLeft(2, '0'),
                  'ثانية',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'موعد الأذان: ${PrayerTimesCalculator.formatTimeOfDay(nextPrayer.time)}',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        ':',
        style: GoogleFonts.notoSans(
          color: AppColors.accentLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDayProgressIndicator(DateTime now) {
    if (_prayerTimes.isEmpty) return const SizedBox.shrink();

    // حساب نسبة تقدم اليوم بناءً على الصلوات
    final firstPrayer = _prayerTimes.first;
    final lastPrayer = _prayerTimes.last;

    final startMinutes = firstPrayer.time.hour * 60 + firstPrayer.time.minute;
    final endMinutes = lastPrayer.time.hour * 60 + lastPrayer.time.minute;
    final currentMinutes = now.hour * 60 + now.minute;

    double progress = 0.0;
    if (currentMinutes > startMinutes) {
      progress = (currentMinutes - startMinutes) / (endMinutes - startMinutes);
    }
    progress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم اليوم',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSunriseCard(PrayerTime sunrise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // أصفر فاتح للشروق
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Text(
            sunrise.arabicName,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
          const Spacer(),
          Text(
            PrayerTimesCalculator.formatTimeOfDay(sunrise.time),
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange[900],
            ),
          ),
        ],
      ),
    );
  }
}

class ModernPrayerTimeCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;
  final bool isPassed;

  const ModernPrayerTimeCard({
    super.key,
    required this.prayer,
    required this.isNext,
    required this.isPassed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isNext
        ? AppColors.primary
        : (isPassed ? Colors.white.withValues(alpha: 0.6) : Colors.white);

    final shadowColor = isNext
        ? AppColors.primary.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isNext
            ? Border.all(color: AppColors.accent, width: 2)
            : Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // أيقونة الصلاة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isNext
                    ? Colors.white.withValues(alpha: 0.15)
                    : (isPassed
                          ? Colors.grey.shade100
                          : AppColors.primary.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                prayer.icon,
                color: isNext
                    ? AppColors.accentLight
                    : (isPassed ? Colors.grey : AppColors.primary),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // اسم الصلاة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.arabicName,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isNext
                          ? Colors.white
                          : (isPassed ? Colors.grey : AppColors.textPrimary),
                    ),
                  ),
                  if (isNext)
                    Text(
                      'يحين الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            // وقت الصلاة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PrayerTimesCalculator.formatTimeOfDay(prayer.time),
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isNext
                        ? Colors.white
                        : (isPassed ? Colors.grey : AppColors.primary),
                  ),
                ),
                if (isPassed)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.grey,
                    size: 14,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpiritualQuoteCard extends StatelessWidget {
  const _SpiritualQuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(
            'قال رسول الله ﷺ: "أَحَبُّ الأَعْمَالِ إِلَى اللهِ الصَّلاةُ عَلَى وَقْتِهَا"',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رواه البخاري ومسلم',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// شاشة مشغل الأذان
class AdhanPlayerScreen extends StatefulWidget {
  final String prayerName;

  const AdhanPlayerScreen({super.key, required this.prayerName});

  @override
  State<AdhanPlayerScreen> createState() => _AdhanPlayerScreenState();
}

class _AdhanPlayerScreenState extends State<AdhanPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _playAdhan();
  }

  Future<void> _playAdhan() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // تشغيل ملف الأذان من assets
      // يجب إضافة ملف adhan.mp3 في مجلد assets/audio/
      await _audioPlayer.setAsset('assets/audio/adhan.mp3');
      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      // الاستماع لانتهاء التشغيل
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'تعذر تشغيل الأذان: $e';
      });
      debugPrint('خطأ في تشغيل الأذان: $e');
    }
  }

  Future<void> _stopAdhan() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة المسجد
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 40),
              // اسم الصلاة
              Text(
                'حان وقت صلاة ${widget.prayerName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'الله أكبر',
                style: TextStyle(
                  color: AppColors.accentLight,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 60),
              // حالة التشغيل
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else if (_error != null)
                Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red[300], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر الإيقاف
                    FloatingActionButton.large(
                      heroTag: 'stop',
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _stopAdhan();
                        if (!mounted) return;
                        navigator.pop();
                      },
                      child: const Icon(Icons.stop, size: 40),
                    ),
                    const SizedBox(width: 30),
                    // زر التشغيل/الإيقاف المؤقت
                    FloatingActionButton.large(
                      heroTag: 'play',
                      backgroundColor: AppColors.accent,
                      onPressed: _togglePlay,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              // مؤثر موجات صوتية (تأثير بصري)
              if (_isPlaying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 30 + (index % 3) * 20,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(
                          alpha: 0.6 + (index % 2) * 0.4,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              // زر إغلاق الشاشة
              TextButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await _stopAdhan();
                  if (!mounted) return;
                  navigator.pop();
                },
                icon: const Icon(Icons.close, color: Colors.white70),
                label: const Text(
                  'إغلاق',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
