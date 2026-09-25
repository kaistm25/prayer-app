import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../main.dart';
import 'tafsir_data.dart';
import 'quran_pak_service.dart';
import 'tafsir_api_service.dart';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isLoadingTafsir = false;
  late QuranPakService _quranPakService;

  @override
  void initState() {
    super.initState();
    _quranPakService = QuranPakService();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });

    // Initialize Quran Pak tafsir data in background
    _initializeTafsir();
  }

  Future<void> _initializeTafsir() async {
    setState(() {
      _isLoadingTafsir = true;
    });

    try {
      await _quranPakService.initializeTafsir();
    } catch (e) {
      debugPrint('Error initializing tafsir: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTafsir = false;
        });
      }
    }
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
      appBar: AppBar(title: const Text('تفسير القرآن الكريم')),
      body: Column(
        children: [
          // مقدمة التفسير
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1B5E3F)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'تفسير القرآن الكريم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'تفسير ابن كثير (تفسير القرآن العظيم)\nللحافظ ابن كثير رحمه الله (ت 774هـ)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
          // مؤشر تحميل التفسير
          if (_isLoadingTafsir)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'جاري تحميل بيانات التفسير الشاملة...',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
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
                final hasTafsir = TafsirData.getAvailableSurahs().contains(n);

                // تدرج لوني مميز
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SurahTafsirScreen(surahNumber: n),
                        ),
                      );
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
                                  color: gradientColors[0].withValues(
                                    alpha: 0.3,
                                  ),
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
                                      isMeccan
                                          ? Icons.mosque
                                          : Icons.location_city,
                                      size: 14,
                                      color: isMeccan
                                          ? const Color(0xFF0D5C36)
                                          : const Color(0xFFB8860B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isMeccan ? 'مكية' : 'مدنية',
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
                                if (hasTafsir)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'التفسير متاح',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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

// شاشة تفسير السورة
class SurahTafsirScreen extends StatefulWidget {
  final int surahNumber;

  const SurahTafsirScreen({super.key, required this.surahNumber});

  @override
  State<SurahTafsirScreen> createState() => _SurahTafsirScreenState();
}

class _SurahTafsirScreenState extends State<SurahTafsirScreen> {
  late final Future<List<Map<String, String>>> _tafsirFuture;

  bool _isDownloading = false;
  bool _cancelRequested = false;
  int _downloadDone = 0;
  static const int _downloadTotal = 114;

  @override
  void initState() {
    super.initState();
    _tafsirFuture = TafsirData.getMuyassarTafsirForSurah(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final surahName = quran.getSurahNameArabic(widget.surahNumber);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(title: Text('تفسير سورة $surahName')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _tafsirFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            final fallback = TafsirData.getTafsirForSurah(widget.surahNumber);
            if (fallback.isEmpty) {
              return Center(
                child: Text(
                  'تعذر تحميل ملفات التفسير من الأصول: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'لم يتم العثور على ملفات التفسير على الجهاز، سيتم عرض التفسير المتاح داخل التطبيق.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isDownloading)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: (_downloadDone / _downloadTotal).clamp(
                                0.0,
                                1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_downloadDone / $_downloadTotal',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _cancelRequested = true;
                                  });
                                },
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('إلغاء'),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final buildContext = context;
                                  setState(() {
                                    _isDownloading = true;
                                    _cancelRequested = false;
                                    _downloadDone = 0;
                                  });
                                  try {
                                    final service = TafsirApiService();
                                    await service.downloadMuyassarSurah(
                                      widget.surahNumber,
                                    );
                                    if (!mounted) return;
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                    if (!buildContext.mounted) return;
                                    Navigator.of(buildContext).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => SurahTafsirScreen(
                                          surahNumber: widget.surahNumber,
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!mounted) return;
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('تنزيل هذه السورة فقط'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final buildContext = context;
                                  setState(() {
                                    _isDownloading = true;
                                    _cancelRequested = false;
                                    _downloadDone = 0;
                                  });
                                  try {
                                    final service = TafsirApiService();
                                    final completed = await service
                                        .downloadAllMuyassarSurahs(
                                          onProgress: (done, total) {
                                            if (!mounted) return;
                                            setState(() {
                                              _downloadDone = done;
                                            });
                                          },
                                          shouldCancel: () => _cancelRequested,
                                        );
                                    if (!mounted) return;
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                    if (!completed) return;
                                    if (!buildContext.mounted) return;
                                    Navigator.of(buildContext).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => SurahTafsirScreen(
                                          surahNumber: widget.surahNumber,
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!mounted) return;
                                    setState(() {
                                      _isDownloading = false;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.cloud_download_rounded),
                                label: const Text('تنزيل جميع السور'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fallback.length,
                    itemBuilder: (context, index) {
                      final item = fallback[index];
                      final isIntro = item['ayah'] == '0';

                      if (isIntro) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['text']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['tafsir']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFF1B5E3F),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'آية ${item['ayah']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.format_quote_rounded,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              color: const Color(0xFFFFF8E1),
                              child: Column(
                                children: [
                                  Text(
                                    item['text']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 2,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if ((item['tafsir'] ?? '').trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.menu_book_rounded,
                                            color: AppColors.primary,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'التفسير',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item['tafsir']!,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                        height: 1.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          final tafsirList =
              snapshot.data ?? TafsirData.getTafsirForSurah(widget.surahNumber);

          if (tafsirList.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد بيانات تفسير متاحة حالياً.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tafsirList.length,
            itemBuilder: (context, index) {
              final item = tafsirList[index];
              final isIntro = item['ayah'] == '0';

              if (isIntro) {
                // عرض مقدمة السورة بشكل مميز
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['tafsir']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // رأس البطاقة - رقم الآية
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF1B5E3F)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'آية ${item['ayah']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.format_quote_rounded,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                    // نص الآية
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFFFF8E1),
                      child: Column(
                        children: [
                          Text(
                            item['text']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((item['tafsir'] ?? '').trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'التفسير',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['tafsir']!,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
