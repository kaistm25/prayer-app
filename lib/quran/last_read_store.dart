import 'package:shared_preferences/shared_preferences.dart';

class LastRead {
  final int surahNumber; // 1..114
  final int ayahNumber; // 1..n

  const LastRead({
    required this.surahNumber,
    required this.ayahNumber,
  });
}

class LastReadStore {
  static const _kSurahKey = 'quran_last_surah';
  static const _kAyahKey = 'quran_last_ayah';

  static Future<LastRead?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_kSurahKey);
    final ayah = prefs.getInt(_kAyahKey);
    if (surah == null || ayah == null) return null;
    if (surah < 1 || surah > 114) return null;
    if (ayah < 1) return null;
    return LastRead(surahNumber: surah, ayahNumber: ayah);
  }

  static Future<void> save({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSurahKey, surahNumber);
    await prefs.setInt(_kAyahKey, ayahNumber);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSurahKey);
    await prefs.remove(_kAyahKey);
  }
}

