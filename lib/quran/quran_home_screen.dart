import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import '../main.dart';
import 'last_read_store.dart';
import 'surah_screen.dart';

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  LastRead? _lastRead;
  bool _loadingLastRead = true;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  Future<void> _loadLastRead() async {
    final last = await LastReadStore.load();
    if (!mounted) return;
    setState(() {
      _lastRead = last;
      _loadingLastRead = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSurahNumbers = List<int>.generate(114, (i) => i + 1);

    final filtered = _query.isEmpty
        ? allSurahNumbers
        : allSurahNumbers.where((n) {
            final name = quran.getSurahNameArabic(n);
            return name.contains(_query);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة (مثال: البقرة)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_loadingLastRead)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_lastRead != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.bookmark_rounded, color: AppColors.primary),
                  title: Text(
                    'متابعة القراءة',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.right,
                  ),
                  subtitle: Text(
                    'آخر موضع: سورة ${quran.getSurahNameArabic(_lastRead!.surahNumber)} - آية ${_lastRead!.ayahNumber}',
                    textAlign: TextAlign.right,
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () async {
                    final last = await LastReadStore.load();
                    if (!context.mounted || last == null) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SurahScreen(
                          surahNumber: last.surahNumber,
                          initialAyah: last.ayahNumber,
                        ),
                      ),
                    );
                    await _loadLastRead();
                  },
                  onLongPress: () async {
                    await LastReadStore.clear();
                    await _loadLastRead();
                  },
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final n = filtered[index];
                final name = quran.getSurahNameArabic(n);
                final verses = quran.getVerseCount(n);
                final isMeccan = quran.getPlaceOfRevelation(n) == "Meccan";
                
                // تدرج لوني مميز لكل سورة
                final gradientColors = isMeccan
                    ? [const Color(0xFF0D5C36), const Color(0xFF1B8A4E)]
                    : [const Color(0xFFB8860B), const Color(0xFFDAA520)];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SurahScreen(surahNumber: n),
                        ),
                      );
                      await _loadLastRead();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // رقم السورة بتصميم دائري
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$n',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  name,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      isMeccan ? Icons.mosque : Icons.location_city,
                                      size: 14,
                                      color: isMeccan 
                                          ? const Color(0xFF0D5C36)
                                          : const Color(0xFFB8860B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isMeccan ? 'مكية' : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMeccan 
                                            ? const Color(0xFF0D5C36)
                                            : const Color(0xFFB8860B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.format_list_numbered,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$verses آية',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

