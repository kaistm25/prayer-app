import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'last_read_store.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyah; // optional jump

  const SurahScreen({super.key, required this.surahNumber, this.initialAyah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late final ScrollController _controller;
  final Map<int, GlobalKey> _verseKeys = {}; // key per ayah for scrolling
  bool _didAutoScroll = false; // avoid repeated scrolling
  int? _resumeAyah;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _loadLastRead();

    // عند بدء الصفحة نحاول الانتقال إلى الآية المرغوبة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ayah = widget.initialAyah;
      if (!mounted || ayah == null || ayah <= 1) return;
      _scrollToAyah(ayah);
    });
  }

  Future<void> _loadLastRead() async {
    final last = await LastReadStore.load();
    if (!mounted || last == null) return;
    if (last.surahNumber != widget.surahNumber) return;
    // دعم التوافق: إذا كانت الفاتحة وقد تم حفظ آية وفق الترقيم الأصلي (2..7)
    // نحولها إلى الترقيم المعروض (1..6). غير ذلك نعرض الرقم كما هو.
    final normalized = widget.surahNumber == 1
        ? (last.ayahNumber >= 2 ? last.ayahNumber - 1 : last.ayahNumber)
        : last.ayahNumber;
    setState(() {
      _resumeAyah = normalized;
    });
  }

  /// ensure the given ayah marker is visible once spans are laid out.
  /// We retry until the embedded key gets a context.
  void _scrollToAyah(int ayah, [int attempt = 0]) {
    if (_didAutoScroll) return;
    if (attempt > 12) return; // give up after a few tries

    final key = _verseKeys[ayah];
    if (key == null || key.currentContext == null) {
      // spans not yet built; wait and try again
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(ayah, attempt + 1);
      });
      return;
    }

    // we have a concrete context; ensure visible and mark done
    Scrollable.ensureVisible(
      key.currentContext!,
      alignment: 0.0,
      duration: const Duration(milliseconds: 150),
    );
    _didAutoScroll = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<InlineSpan> _buildVerseSpans({
    required bool hasBismillah,
  }) {
    final List<InlineSpan> spans = [];
    final count = quran.getVerseCount(widget.surahNumber);

    final isFatiha = widget.surahNumber == 1;

    if (isFatiha) {
      final displayedCount = count - 1; // إخفاء البسملة كنص داخل الفقرة
      for (int display = 1; display <= displayedCount; display++) {
        final srcAyah = display + 1;
        final key = _verseKeys.putIfAbsent(display, () => GlobalKey());
        final coreText = quran.getVerse(
          widget.surahNumber,
          srcAyah,
          verseEndSymbol: false,
        );

        final isInitial =
            widget.initialAyah != null && display == widget.initialAyah;
        final isResume = _resumeAyah != null && display == _resumeAyah;

        // رقم الآية بتصميم المصحف التقليدي
        final ayahWidget = WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isResume
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isResume
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              '$display',
              style: GoogleFonts.scheherazadeNew(
                textStyle: TextStyle(
                  fontSize: 18,
                  height: 1,
                  color: isResume ? AppColors.primary : AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );

        spans.add(WidgetSpan(
          child: SizedBox.shrink(key: key),
        ));

        spans.add(TextSpan(
          text: coreText,
          style: GoogleFonts.scheherazadeNew(
            textStyle: TextStyle(
              fontSize: 28,
              height: 2.0,
              color: isResume ? AppColors.primary : AppColors.textPrimary,
              backgroundColor: isResume
                  ? const Color(0xFFE8F5E9) // أخضر فاتح جداً للآية المحفوظة
                  : null,
              decoration: isResume
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: isResume
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : null,
              decorationThickness: isResume ? 2 : null,
              fontWeight:
                  (isInitial || isResume) ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await LastReadStore.save(
                surahNumber: widget.surahNumber,
                ayahNumber: display,
              );
              setState(() {
                _resumeAyah = display;
              });
              if (!mounted) return;
              final name = quran.getSurahNameArabic(widget.surahNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ آخر موضع: سورة $name - آية $display'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
        ));

        // إضافة رقم الآية
        spans.add(ayahWidget);

        if (display != displayedCount) {
          spans.add(const TextSpan(text: '  '));
        }
      }
    } else {
      for (int ayah = 1; ayah <= count; ayah++) {
        final key = _verseKeys.putIfAbsent(ayah, () => GlobalKey());
        var coreText = quran.getVerse(
          widget.surahNumber,
          ayah,
          verseEndSymbol: false,
        );
        if (ayah == 1 && widget.surahNumber != 9) {
          // keep basmala as part of verse
        }

        final isInitial =
            widget.initialAyah != null && ayah == widget.initialAyah;
        final isResume = _resumeAyah != null && ayah == _resumeAyah;

        // رقم الآية بتصميم المصحف التقليدي
        final ayahWidget = WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isResume
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isResume
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.accent.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              '$ayah',
              style: GoogleFonts.scheherazadeNew(
                textStyle: TextStyle(
                  fontSize: 18,
                  height: 1,
                  color: isResume ? AppColors.primary : AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );

        spans.add(WidgetSpan(
          child: SizedBox.shrink(key: key),
        ));

        spans.add(TextSpan(
          text: coreText,
          style: GoogleFonts.scheherazadeNew(
            textStyle: TextStyle(
              fontSize: 28,
              height: 2.0,
              color: isResume ? AppColors.primary : AppColors.textPrimary,
              backgroundColor: isResume
                  ? const Color(0xFFE8F5E9) // أخضر فاتح جداً للآية المحفوظة
                  : null,
              decoration: isResume
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: isResume
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : null,
              decorationThickness: isResume ? 2 : null,
              fontWeight:
                  (isInitial || isResume) ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              await LastReadStore.save(
                surahNumber: widget.surahNumber,
                ayahNumber: ayah,
              );
              setState(() {
                _resumeAyah = ayah;
              });
              if (!mounted) return;
              final name = quran.getSurahNameArabic(widget.surahNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ آخر موضع: سورة $name - آية $ayah'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
        ));

        // إضافة رقم الآية
        spans.add(ayahWidget);

        if (ayah != count) {
          spans.add(const TextSpan(text: '  '));
        }
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final name = quran.getSurahNameArabic(widget.surahNumber);
    final count = quran.getVerseCount(widget.surahNumber);
    final hasBismillah = widget.surahNumber != 9;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0), // لون بيج فاتح هادئ للصفحة
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'سورة $name'),
              const TextSpan(text: '  •  '),
              TextSpan(text: '$count آية'),
            ],
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.scheherazadeNew(
                    textStyle: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${quran.getPlaceOfRevelation(widget.surahNumber) == "Meccan" ? "مكية" : ""} • $count آية',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                if (hasBismillah)
                  const SizedBox(height: 12),
                const Divider(height: 16, thickness: 1),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: RichText(
                textAlign: TextAlign.justify,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                ),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 2.0,
                  fontSize: 28,
                ),
                text: TextSpan(
                  style: GoogleFonts.scheherazadeNew(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      height: 2.0,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: _buildVerseSpans(hasBismillah: hasBismillah),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SurahFooterNavigator(current: widget.surahNumber),
        ],
      ),
    );
  }
}

class _SurahFooterNavigator extends StatelessWidget {
  final int current;
  const _SurahFooterNavigator({required this.current});

  @override
  Widget build(BuildContext context) {
    final prev = current > 1 ? current - 1 : null;
    final next = current < 114 ? current + 1 : null;
    final prevName = prev != null ? quran.getSurahNameArabic(prev) : null;
    final nextName = next != null ? quran.getSurahNameArabic(next) : null;

    Widget buildGradientButton({
      required VoidCallback onTap,
      required List<Color> colors,
      required Widget child,
    }) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (prev != null)
          buildGradientButton(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => SurahScreen(surahNumber: prev)),
              );
            },
            colors: [
              AppColors.primaryDark.withValues(alpha: 0.95),
              AppColors.primary.withValues(alpha: 0.85),
            ],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
                Text(
                  'السابق: $prevName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        if (prev != null && next != null) const SizedBox(height: 12),
        if (next != null)
          buildGradientButton(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => SurahScreen(surahNumber: next)),
              );
            },
            colors: [
              AppColors.primary.withValues(alpha: 0.9),
              AppColors.accent.withValues(alpha: 0.8),
            ],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8),
                Text(
                  'التالي: $nextName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
              ],
            ),
          ),
      ],
    );
  }
}
