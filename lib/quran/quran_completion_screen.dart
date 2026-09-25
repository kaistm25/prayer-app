import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class QuranCompletionScreen extends StatefulWidget {
  const QuranCompletionScreen({super.key});

  @override
  State<QuranCompletionScreen> createState() => _QuranCompletionScreenState();
}

class _QuranCompletionScreenState extends State<QuranCompletionScreen> {
  int? _selectedDays;
  final List<int> _dayOptions = [7, 14, 30, 60, 90, 120];
  final Map<int, List<Map<String, dynamic>>> _dailyVerses = {};
  final Map<int, Set<int>> _readVerses =
      {}; // day -> set of verse indices that are read
  final Map<int, int> _lastReadAyahIndices = {}; // day -> last read ayah index
  int _totalVersesRead = 0;
  bool _notificationEnabled = false;
  final Map<int, DateTime> _completedDaysDates = {};

  @override
  void initState() {
    super.initState();
    // Faster visibility detection for auto-progress
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 100,
    );
    _loadProgress();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('quran_daily_notification') ?? false;
    });
  }

  Future<void> _toggleDailyNotification(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quran_daily_notification', enable);

    if (enable) {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        debugPrint('⚠ الإشعارات المجدولة غير مدعومة حالياً على هذا النظام');
        setState(() {
          _notificationEnabled = false;
        });
        // إظهار تنبيه للمستخدم
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'الإشعارات المجدولة مدعومة فقط على أندرويد و iOS حالياً',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      try {
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        if (Platform.isAndroid || Platform.isIOS) {
          final now = tz.TZDateTime.now(tz.local);
          var scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            8,
            0,
          );
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          await flutterLocalNotificationsPlugin.zonedSchedule(
            999,
            'تذكير ختم القرآن',
            'حان وقت قراءة آيات اليوم من القرآن الكريم',
            scheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'quran_daily_channel',
                'إشعارات ختم القرآن',
                channelDescription: 'إشعار يومي لتذكير قراءة القرآن',
                importance: Importance.high,
                priority: Priority.high,
                ticker: 'تذكير ختم القرآن',
                styleInformation: DefaultStyleInformation(true, true),
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'quran_daily_reminder',
          );
        }
      } catch (e) {
        debugPrint('خطأ في جدولة الإشعارات: $e');
      }
    } else {
      try {
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.cancel(999);
      } catch (e) {
        debugPrint('Error canceling notification: $e');
      }
    }

    setState(() {
      _notificationEnabled = enable;
    });
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getInt('quran_completion_days');

    _completedDaysDates.clear();
    for (int day = 1; day <= 120; day++) {
      final dateString = prefs.getString('quran_completion_day_${day}_date');
      if (dateString != null) {
        _completedDaysDates[day] = DateTime.parse(dateString);
      }
    }

    if (days != null) {
      setState(() {
        _selectedDays = days;
        _calculateDailyVerses(days);
        _loadDayProgress();
      });
    }
  }

  void _calculateDailyVerses(int days) {
    const totalVerses = 6236;
    final versesPerDay = (totalVerses / days).ceil();
    int currentVerse = 1;
    int currentSurah = 1;
    int verseInSurah = 1;

    _dailyVerses.clear();

    for (int day = 1; day <= days; day++) {
      List<Map<String, dynamic>> dayVerses = [];
      int versesForDay = versesPerDay;
      if (day == days) {
        versesForDay = totalVerses - (day - 1) * versesPerDay;
      }

      for (int i = 0; i < versesForDay && currentVerse <= totalVerses; i++) {
        while (verseInSurah > quran.getVerseCount(currentSurah)) {
          currentSurah++;
          verseInSurah = 1;
        }
        final verseText = quran.getVerse(currentSurah, verseInSurah);
        final surahName = quran.getSurahNameArabic(currentSurah);
        dayVerses.add({
          'surah': currentSurah,
          'verse': verseInSurah,
          'text': verseText,
          'surahName': surahName,
        });
        verseInSurah++;
        currentVerse++;
      }
      _dailyVerses[day] = dayVerses;
    }
  }

  Future<void> _loadDayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _readVerses.clear();
    _lastReadAyahIndices.clear();
    _totalVersesRead = 0;

    for (int day = 1; day <= (_selectedDays ?? 0); day++) {
      final readVersesString =
          prefs.getString('quran_completion_read_verses_$day') ?? '';
      final readVerses = readVersesString.isNotEmpty
          ? readVersesString.split(',').map(int.parse).toSet()
          : <int>{};
      _readVerses[day] = readVerses;
      _totalVersesRead += readVerses.length;

      final lastAyahIndex = prefs.getInt('quran_last_ayah_index_day_$day');
      if (lastAyahIndex != null) {
        _lastReadAyahIndices[day] = lastAyahIndex;
      }
    }
    setState(() {});
  }

  Future<void> _selectDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_completion_days', days);

    setState(() {
      _selectedDays = days;
      _calculateDailyVerses(days);
      _loadDayProgress();
    });
  }

  Future<void> _resetPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Remove all keys related to quran completion
    for (String key in keys) {
      if (key.startsWith('quran_completion_') ||
          key.startsWith('quran_last_ayah_index_day_')) {
        await prefs.remove(key);
      }
    }

    setState(() {
      _selectedDays = null;
      _dailyVerses.clear();
      _readVerses.clear();
      _lastReadAyahIndices.clear();
      _totalVersesRead = 0;
      _completedDaysDates.clear();
    });
  }

  double get _overallProgress {
    if (_selectedDays == null) {
      return 0.0;
    }
    return _totalVersesRead / 6236;
  }

  Future<void> _markVerseRead(int day, int verseIndex, bool read) async {
    final prefs = await SharedPreferences.getInstance();
    final readVerses = _readVerses[day] ?? <int>{};

    if (read) {
      readVerses.add(verseIndex);
      _lastReadAyahIndices[day] = verseIndex;
      await prefs.setInt('quran_last_ayah_index_day_$day', verseIndex);
    } else {
      readVerses.remove(verseIndex);
      if (_lastReadAyahIndices[day] == verseIndex) {
        if (readVerses.isNotEmpty) {
          final previousIndex = readVerses.reduce((a, b) => a > b ? a : b);
          _lastReadAyahIndices[day] = previousIndex;
          await prefs.setInt('quran_last_ayah_index_day_$day', previousIndex);
        } else {
          _lastReadAyahIndices.remove(day);
          await prefs.remove('quran_last_ayah_index_day_$day');
        }
      }
    }

    await prefs.setString(
      'quran_completion_read_verses_$day',
      readVerses.join(','),
    );
    await _loadDayProgress();
  }

  Future<void> _markDayCompleted(int day, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final verses = _dailyVerses[day] ?? [];
    final readVerses = _readVerses[day] ?? <int>{};

    if (completed) {
      for (int i = 0; i < verses.length; i++) {
        readVerses.add(i);
      }
      final completionDate = DateTime.now();
      _completedDaysDates[day] = completionDate;
      await prefs.setString(
        'quran_completion_day_${day}_date',
        completionDate.toIso8601String(),
      );
      if (verses.isNotEmpty) {
        _lastReadAyahIndices[day] = verses.length - 1;
        await prefs.setInt('quran_last_ayah_index_day_$day', verses.length - 1);
      }
    } else {
      readVerses.clear();
      _completedDaysDates.remove(day);
      await prefs.remove('quran_completion_day_${day}_date');
      _lastReadAyahIndices.remove(day);
      await prefs.remove('quran_last_ayah_index_day_$day');
    }

    await prefs.setString(
      'quran_completion_read_verses_$day',
      readVerses.join(','),
    );
    await _loadDayProgress();
  }

  Future<void> _saveLastReadPosition(int day, double offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_completion_scroll_offset_$day', offset);
  }

  Future<double> _getLastReadPosition(int day) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('quran_completion_scroll_offset_$day') ?? 0.0;
  }

  void _showDayVerses(BuildContext context, int day) async {
    final verses = _dailyVerses[day] ?? [];
    double? initialScrollPosition = await _getLastReadPosition(day);

    if (!context.mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final readVerses = _readVerses[day] ?? <int>{};
          final isCompleted = readVerses.length == verses.length;

          return PopScope(
            onPopInvokedWithResult: (result, didPop) {
              if (mounted) {
                setState(() {});
              }
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 0.99,
              minChildSize: 0.5,
              builder: (context, innerScrollController) {
                if (initialScrollPosition != null &&
                    initialScrollPosition! > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (innerScrollController.hasClients &&
                        initialScrollPosition != null) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (innerScrollController.hasClients &&
                            initialScrollPosition != null) {
                          innerScrollController.animateTo(
                            initialScrollPosition!.clamp(
                              0,
                              innerScrollController.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                          initialScrollPosition = null;
                        }
                      });
                    }
                  });
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFBF7),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ورد اليوم $day',
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                  Text(
                                    '${readVerses.length} من ${verses.length} آية مكتملة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _markDayCompleted(
                                    day,
                                    !isCompleted,
                                  ).then((_) => setModalState(() {})),
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.undo_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    isCompleted ? 'تراجع' : 'تم الكل',
                                    style: GoogleFonts.cairo(),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted
                                        ? Colors.grey[400]
                                        : const Color(0xFF1B5E20),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close_rounded),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification) {
                              _saveLastReadPosition(
                                day,
                                innerScrollController.offset,
                              );
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: innerScrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                _buildQuranText(
                                  verses,
                                  readVerses,
                                  setModalState,
                                  day,
                                ),
                                if (!isCompleted && day < (_selectedDays ?? 0))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await _markDayCompleted(day, true);
                                        if (!context.mounted) {
                                          return;
                                        }
                                        Navigator.of(context).pop();
                                        await Future.delayed(
                                          const Duration(milliseconds: 300),
                                        );
                                        if (context.mounted) {
                                          _showDayVerses(context, day + 1);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward_rounded,
                                      ),
                                      label: Text(
                                        'تم، انتقل لليوم التالي',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFD4AF37,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuranText(
    List<Map<String, dynamic>> verses,
    Set<int> readVerses,
    StateSetter setModalState,
    int day,
  ) {
    List<Widget> quranWidgets = [];
    int currentSurah = -1;
    List<InlineSpan> currentSurahSpans = [];

    void flushCurrentSurahSpans() {
      if (currentSurahSpans.isNotEmpty) {
        quranWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RichText(
              textAlign: TextAlign.justify,
              textDirection: ui.TextDirection.rtl,
              text: TextSpan(children: List.from(currentSurahSpans)),
            ),
          ),
        );
        currentSurahSpans.clear();
      }
    }

    for (int index = 0; index < verses.length; index++) {
      final verse = verses[index];
      final isRead = readVerses.contains(index);
      final surahNumber = verse['surah'];
      final verseNumber = verse['verse'];
      final verseText = verse['text'];

      if (surahNumber != currentSurah) {
        flushCurrentSurahSpans();
        if (currentSurah != -1) {
          quranWidgets.add(
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'صدق الله العظيم',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),
          );
        }

        quranWidgets.add(
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                '✧ سورة ${verse['surahName']} ✧',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
        );

        if (surahNumber != 9) {
          quranWidgets.add(
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
              ),
            ),
          );
        }
        currentSurah = surahNumber;
      }

      currentSurahSpans.add(
        TextSpan(
          text: '$verseText ',
          style: GoogleFonts.scheherazadeNew(
            fontSize: 28,
            height: 2.0,
            color: Colors.black87,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await _markVerseRead(day, index, !isRead);
              setModalState(() {});
            },
        ),
      );

      currentSurahSpans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: VisibilityDetector(
            key: Key('verse_day_${day}_index_$index'),
            onVisibilityChanged: (visibilityInfo) async {
              if (visibilityInfo.visibleFraction > 0.1) {
                if (_lastReadAyahIndices[day] != index) {
                  _lastReadAyahIndices[day] = index;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('quran_last_ayah_index_day_$day', index);
                  if (!isRead) {
                    await _markVerseRead(day, index, true);
                    setModalState(() {});
                  }
                }
              }
            },
            child: GestureDetector(
              onTap: () async {
                await _markVerseRead(day, index, !isRead);
                setModalState(() {});
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isRead
                      ? const Color(0xFF1B5E20).withValues(alpha: 0.1)
                      : const Color(0xFFD4AF37).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isRead
                        ? const Color(0xFF1B5E20).withValues(alpha: 0.4)
                        : const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    verseNumber.toString(),
                    style: GoogleFonts.scheherazadeNew(
                      color: isRead ? const Color(0xFF1B5E20) : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if (index < verses.length - 1) {
        currentSurahSpans.add(const TextSpan(text: '  '));
      }
    }
    flushCurrentSurahSpans();
    return Column(children: quranWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: _selectedDays == null ? _buildDaySelection() : _buildProgressView(),
    );
  }

  Widget _buildDaySelection() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFF1B5E20),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    Text(
                      'ختم القرآن الكريم',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ابدأ رحلة الختمة',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'اختر المدة الزمنية المناسبة لختم المصحف الشريف',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final days = _dayOptions[index];
              final versesPerDay = (6236 / days).ceil();
              IconData optionIcon = days <= 14
                  ? Icons.bolt_rounded
                  : (days <= 30
                        ? Icons.calendar_today_rounded
                        : Icons.history_rounded);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.05),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectDays(days),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1B5E20,
                              ).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              optionIcon,
                              color: const Color(0xFF1B5E20),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '$days يوم',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$versesPerDay آية/يوم',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }, childCount: _dayOptions.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  int? get _lastCompletedDay {
    int? lastDay;
    for (int day = 1; day <= (_selectedDays ?? 0); day++) {
      final verses = _dailyVerses[day] ?? [];
      final readVerses = _readVerses[day] ?? <int>{};
      if (readVerses.length == verses.length && verses.isNotEmpty) {
        lastDay = day;
      }
    }
    return lastDay;
  }

  Widget _buildProgressView() {
    final completedDays = _readVerses.entries
        .where(
          (entry) =>
              entry.value.length == (_dailyVerses[entry.key]?.length ?? 0),
        )
        .length;
    final totalDays = _selectedDays ?? 0;
    final lastCompleted = _lastCompletedDay;
    const primaryColor = Color(0xFF1B5E20);
    const accentColor = Color(0xFFD4AF37);
    final currentReadingDay = (lastCompleted ?? 0) + 1;

    return Container(
      color: const Color(0xFFFDFBF7),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF2E7D32)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Opacity(
                        opacity: 0.1,
                        child: const Icon(
                          Icons.mosque_rounded,
                          size: 250,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'البدء من جديد؟',
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: Text(
                                            'سيتم مسح جميع التقدم الحالي والبدء بخطة جديدة. هل أنت متأكد؟',
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.cairo(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'إلغاء',
                                                style: GoogleFonts.cairo(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _resetPlan();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'نعم، ابدأ من جديد',
                                                style: GoogleFonts.cairo(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    tooltip: 'البدء من جديد',
                                  ),
                                ],
                              ),
                              Text(
                                'رحلة الختمة',
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _toggleDailyNotification(
                                  !_notificationEnabled,
                                ),
                                icon: Icon(
                                  _notificationEnabled
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                tooltip: _notificationEnabled
                                    ? 'تعطيل التنبيهات'
                                    : 'تفعيل التنبيهات اليومية',
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'نسبة الإنجاز الكلية',
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(_overallProgress * 100).toInt()}%',
                                          style: GoogleFonts.cairo(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _overallProgress,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatItem(
                        '$_totalVersesRead',
                        'آية مقروءة',
                        Icons.menu_book_rounded,
                        const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        '${6236 - _totalVersesRead}',
                        'آية متبقية',
                        Icons.bookmark_outline,
                        const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        '$completedDays/$totalDays',
                        'أيام مكتملة',
                        Icons.calendar_today_rounded,
                        accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (currentReadingDay <= totalDays)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showDayVerses(context, currentReadingDay),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'استكمال الورد - اليوم $currentReadingDay',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الجدول الزمني',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'إعادة الضبط',
                            style: GoogleFonts.cairo(),
                          ),
                          content: Text(
                            'هل تود تغيير عدد أيام الختمة؟ سيتم الحفاظ على تقدمك الحالي.',
                            style: GoogleFonts.cairo(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('إلغاء', style: GoogleFonts.cairo()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedDays = null;
                                });
                              },
                              child: Text(
                                'تغيير',
                                style: GoogleFonts.cairo(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: Text(
                      'تعديل الخطة',
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final day = index + 1;
                final verses = _dailyVerses[day] ?? [];
                final readVerses = _readVerses[day] ?? <int>{};
                final isCompleted =
                    readVerses.length == verses.length && verses.isNotEmpty;
                final isCurrent = day == currentReadingDay;
                final isLocked = day > currentReadingDay;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDayTile(
                    day,
                    verses,
                    readVerses,
                    isCompleted,
                    isCurrent,
                    isLocked,
                  ),
                );
              }, childCount: totalDays),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(
    int day,
    List<Map<String, dynamic>> verses,
    Set<int> readVerses,
    bool isCompleted,
    bool isCurrent,
    bool isLocked,
  ) {
    final progress = verses.isNotEmpty
        ? readVerses.length / verses.length
        : 0.0;
    const primaryColor = Color(0xFF1B5E20);
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent
              ? primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : () => _showDayVerses(context, day),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? primaryColor.withValues(alpha: 0.1)
                        : (isCurrent
                              ? const Color(0xFFD4AF37).withValues(alpha: 0.1)
                              : Colors.grey[100]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: primaryColor,
                            size: 32,
                          )
                        : Text(
                            '$day',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? const Color(0xFFD4AF37)
                                  : Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'اليوم $day',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.grey : primaryColor,
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'قيد القراءة',
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${verses.length} آية • تم إنجاز ${readVerses.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? primaryColor
                                : const Color(0xFFD4AF37),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isLocked
                      ? Icons.lock_outline_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isLocked ? Colors.grey[400] : primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
