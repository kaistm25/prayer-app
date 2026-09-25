import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TafsirApiService {
  static const String baseUrl =
      'https://raw.githubusercontent.com/semarketir/quranjson/master/source';

  static final Map<int, Map<String, dynamic>> _muyassarCache = {};

  Future<Directory> _getMuyassarDir() async {
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory(
      '${baseDir.path}${Platform.pathSeparator}tafsir${Platform.pathSeparator}muyassar',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _getMuyassarFile(int surahNumber) async {
    final dir = await _getMuyassarDir();
    return File('${dir.path}${Platform.pathSeparator}surah_$surahNumber.json');
  }

  Future<bool> isSurahDownloaded(int surahNumber) async {
    final file = await _getMuyassarFile(surahNumber);
    return file.exists();
  }

  Future<bool> isAllDownloaded() async {
    for (int s = 1; s <= 114; s++) {
      if (!await isSurahDownloaded(s)) return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> fetchMuyassarForSurahFromLocal(
    int surahNumber,
  ) async {
    final cached = _muyassarCache[surahNumber];
    if (cached != null) {
      return cached;
    }

    final file = await _getMuyassarFile(surahNumber);
    final jsonString = await file.readAsString();

    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected tafsir payload format');
    }

    _muyassarCache[surahNumber] = decoded;
    return decoded;
  }

  Future<Map<String, dynamic>> fetchMuyassarForSurahFromAssets(
    int surahNumber,
  ) async {
    final cached = _muyassarCache[surahNumber];
    if (cached != null) {
      return cached;
    }

    final assetPath = 'assets/tafsir/surah_$surahNumber.json';
    final jsonString = await rootBundle.loadString(assetPath);

    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected tafsir payload format');
    }

    _muyassarCache[surahNumber] = decoded;
    return decoded;
  }

  Future<void> downloadMuyassarSurah(int surahNumber) async {
    final url = Uri.parse(
      '$baseUrl/translation/ar/ar_translation_$surahNumber.json',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch tafsir (HTTP ${response.statusCode})');
    }

    final jsonString = utf8.decode(response.bodyBytes);

    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected tafsir payload format');
    }

    final file = await _getMuyassarFile(surahNumber);
    await file.writeAsString(jsonString);
    _muyassarCache[surahNumber] = decoded;
  }

  Future<bool> downloadAllMuyassarSurahs({
    void Function(int done, int total)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    const total = 114;
    for (int s = 1; s <= total; s++) {
      if (shouldCancel?.call() == true) {
        return false;
      }
      if (!await isSurahDownloaded(s)) {
        await downloadMuyassarSurah(s);
      }
      onProgress?.call(s, total);
    }

    return true;
  }

  Future<Map<String, dynamic>> fetchMuyassarForSurah(int surahNumber) async {
    final cached = _muyassarCache[surahNumber];
    if (cached != null) {
      return cached;
    }

    final url = Uri.parse(
      '$baseUrl/translation/ar/ar_translation_$surahNumber.json',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch tafsir (HTTP ${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected tafsir payload format');
    }

    _muyassarCache[surahNumber] = decoded;
    return decoded;
  }

  Future<Map<int, String>> fetchMuyassarVersesMap(int surahNumber) async {
    Map<String, dynamic> payload;
    try {
      payload = await fetchMuyassarForSurahFromLocal(surahNumber);
    } catch (_) {
      try {
        payload = await fetchMuyassarForSurahFromAssets(surahNumber);
      } catch (_) {
        rethrow;
      }
    }

    final verseObj = payload['verse'];
    if (verseObj is! Map) {
      throw Exception('Invalid tafsir payload: missing verse map');
    }

    final Map<int, String> result = {};
    for (final entry in verseObj.entries) {
      final key = entry.key.toString();
      if (!key.startsWith('verse_')) continue;

      final verseNumStr = key.substring('verse_'.length);
      final verseNum = int.tryParse(verseNumStr);
      if (verseNum == null) continue;

      result[verseNum] = entry.value?.toString() ?? '';
    }

    return result;
  }

  Future<Map<int, String>> fetchMuyassarVersesMapFromNetwork(
    int surahNumber,
  ) async {
    final payload = await fetchMuyassarForSurah(surahNumber);

    final verseObj = payload['verse'];
    if (verseObj is! Map) {
      throw Exception('Invalid tafsir payload: missing verse map');
    }

    final Map<int, String> result = {};
    for (final entry in verseObj.entries) {
      final key = entry.key.toString();
      if (!key.startsWith('verse_')) continue;

      final verseNumStr = key.substring('verse_'.length);
      final verseNum = int.tryParse(verseNumStr);
      if (verseNum == null) continue;

      result[verseNum] = entry.value?.toString() ?? '';
    }

    return result;
  }

  void clearCache() {
    debugPrint('Clearing TafsirApiService cache');
    _muyassarCache.clear();
  }
}
