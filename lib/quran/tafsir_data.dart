import 'package:quran/quran.dart' as quran;
import 'tafsir_ibn_kathir.dart';
import 'quran_pak_service.dart';
import 'tafsir_api_service.dart';

class TafsirData {
  // التفسير التفصيلي من تفسير ابن كثير للسور الرئيسية
  static final Map<int, List<Map<String, String>>> tafsirBySurah = {
    // تفسير الفاتحة كاملاً من ابن كثير
    1: TafsirIbnKathir.getSurahTafsir(1),
    // تفسير البقرة (الآيات المختارة) من ابن كثير
    2: TafsirIbnKathir.getSurahTafsir(2),
    // تفسير المعوذات من ابن كثير
    112: TafsirIbnKathir.getSurahTafsir(112),
    113: TafsirIbnKathir.getSurahTafsir(113),
    114: TafsirIbnKathir.getSurahTafsir(114),
  };

  // معلومات عامة عن السور
  static final Map<int, Map<String, String>> surahInfo = {
    1: {
      'name': 'الفاتحة',
      'type': 'مكية',
      'description': 'افتتاح القرآن، وأعظم سورة فيه',
    },
    2: {
      'name': 'البقرة',
      'type': 'مدنية',
      'description': 'أطول سورة في القرآن، تضم آية الكرسي',
    },
    3: {
      'name': 'آل عمران',
      'type': 'مدنية',
      'description': 'تتحدث عن أهل الكتاب والجهاد',
    },
    4: {
      'name': 'النساء',
      'type': 'مدنية',
      'description': 'تشريعات في النساء والميراث',
    },
    5: {
      'name': 'المائدة',
      'type': 'مدنية',
      'description': 'آخر سورة نزلت، تتحدث عن العقود',
    },
    6: {
      'name': 'الأنعام',
      'type': 'مكية',
      'description': 'تتحدث عن التوحيد وخلق الأنعام',
    },
    7: {
      'name': 'الأعراف',
      'type': 'مكية',
      'description': 'قصص الأنبياء ويوم القيامة',
    },
    8: {
      'name': 'الأنفال',
      'type': 'مدنية',
      'description': 'غنائم غزوة بدر والاستعداد للقتال',
    },
    9: {
      'name': 'التوبة',
      'type': 'مدنية',
      'description': 'البراءة من المشركين والجهاد',
    },
    10: {
      'name': 'يونس',
      'type': 'مكية',
      'description': 'قصة النبي يونس عليه السلام',
    },
    11: {
      'name': 'هود',
      'type': 'مكية',
      'description': 'قصة هود وصالح وشعيب ونوح',
    },
    12: {
      'name': 'يوسف',
      'type': 'مكية',
      'description': 'قصة يوسف عليه السلام كاملة',
    },
    13: {
      'name': 'الرعد',
      'type': 'مدنية',
      'description': 'العنكبوت وتأمل في الكون',
    },
    14: {
      'name': 'إبراهيم',
      'type': 'مكية',
      'description': 'دعاء إبراهيم للوالدين',
    },
    15: {
      'name': 'الحجر',
      'type': 'مكية',
      'description': 'قوم صالح وإهلاك المدائن',
    },
    16: {
      'name': 'النحل',
      'type': 'مكية',
      'description': 'الأنعام ونعم الله على الإنسان',
    },
    17: {
      'name': 'الإسراء',
      'type': 'مكية',
      'description': 'الإسراء بالنبي وإسرائيليات',
    },
    18: {
      'name': 'الكهف',
      'type': 'مكية',
      'description': 'أصحاب الكهف والخضر وموسى',
    },
    19: {'name': 'مريم', 'type': 'مكية', 'description': 'قصة مريم وولدها عيسى'},
    20: {'name': 'طه', 'type': 'مكية', 'description': 'قصة موسى عليه السلام'},
    21: {
      'name': 'الأنبياء',
      'type': 'مكية',
      'description': 'ذكر عدد من الأنبياء',
    },
    22: {'name': 'الحج', 'type': 'مدنية', 'description': 'أحكام الحج والمناسك'},
    23: {
      'name': 'المؤمنون',
      'type': 'مكية',
      'description': 'صفات المؤمنين وخلق الإنسان',
    },
    24: {'name': 'النور', 'type': 'مدنية', 'description': 'أحكام الزنا والقذف'},
    25: {
      'name': 'الفرقان',
      'type': 'مكية',
      'description': 'الفرقان بين الحق والباطل',
    },
    26: {
      'name': 'الشعراء',
      'type': 'مكية',
      'description': 'قصص الأنبياء وإنكار الشعراء',
    },
    27: {
      'name': 'النمل',
      'type': 'مكية',
      'description': 'قصة سليمان وملكة سبأ',
    },
    28: {
      'name': 'القصص',
      'type': 'مكية',
      'description': 'قصة موسى وهروبه من مصر',
    },
    29: {
      'name': 'العنكبوت',
      'type': 'مكية',
      'description': 'مثل المؤمنين بعنكبوت',
    },
    30: {'name': 'الروم', 'type': 'مكية', 'description': 'وعد الله بنصر الروم'},
    31: {'name': 'لقمان', 'type': 'مكية', 'description': 'حكمة لقمان لابنه'},
    32: {
      'name': 'السجدة',
      'type': 'مكية',
      'description': 'السجود لله وخلق السماوات',
    },
    33: {
      'name': 'الأحزاب',
      'type': 'مدنية',
      'description': 'غزوة الأحزاب وأحكام الأسرى',
    },
    34: {'name': 'سبأ', 'type': 'مكية', 'description': 'قوم سبأ وسد مأرب'},
    35: {'name': 'فاطر', 'type': 'مكية', 'description': 'الشيطان عدو للإنسان'},
    36: {
      'name': 'يس',
      'type': 'مكية',
      'description': 'قلب القرآن، قصة أصحاب القرية',
    },
    37: {
      'name': 'الصافات',
      'type': 'مكية',
      'description': 'الملائكة الصافين وإبراهيم',
    },
    38: {'name': 'ص', 'type': 'مكية', 'description': 'ذكر داود وسليمان وأيوب'},
    39: {
      'name': 'الزمر',
      'type': 'مكية',
      'description': 'التوبة وعدم التشفى بالكفار',
    },
    40: {'name': 'غافر', 'type': 'مكية', 'description': 'المؤمن من آل فرعون'},
    41: {'name': 'فصلت', 'type': 'مكية', 'description': 'أصول الدين والقرآن'},
    42: {'name': 'الشورى', 'type': 'مكية', 'description': 'الشورى والصبر'},
    43: {
      'name': 'الزخرف',
      'type': 'مكية',
      'description': 'الزخرف في الدين والسحر',
    },
    44: {
      'name': 'الدخان',
      'type': 'مكية',
      'description': 'الدخان العذاب ويوم الفصل',
    },
    45: {'name': 'الجاثية', 'type': 'مكية', 'description': 'الجاثية والفرقان'},
    46: {'name': 'الأحقاف', 'type': 'مكية', 'description': 'قوم عاد والأحقاف'},
    47: {
      'name': 'محمد',
      'type': 'مدنية',
      'description': 'القتال والجهاد في سبيل الله',
    },
    48: {
      'name': 'الفتح',
      'type': 'مدنية',
      'description': 'صلح الحديبية وفتح مكة',
    },
    49: {
      'name': 'الحجرات',
      'type': 'مدنية',
      'description': 'آداب المجالس والتحقق',
    },
    50: {'name': 'ق', 'type': 'مكية', 'description': 'القرآن المجيد وقصة آدم'},
    51: {
      'name': 'الذاريات',
      'type': 'مكية',
      'description': 'الذاريات والوعد الحق',
    },
    52: {
      'name': 'الطور',
      'type': 'مكية',
      'description': 'الطور وجزاء المحسنين',
    },
    53: {'name': 'النجم', 'type': 'مكية', 'description': 'النجم وغار حراء'},
    54: {
      'name': 'القمر',
      'type': 'مكية',
      'description': 'انشقاق القمر وقوم نوح',
    },
    55: {
      'name': 'الرحمن',
      'type': 'مدنية',
      'description': 'نعم الله والإنسان والجن',
    },
    56: {
      'name': 'الواقعة',
      'type': 'مكية',
      'description': 'الواقعة وأصحاب الميمنة',
    },
    57: {
      'name': 'الحديد',
      'type': 'مدنية',
      'description': 'الإيمان بالغيب والصدقات',
    },
    58: {
      'name': 'المجادلة',
      'type': 'مدنية',
      'description': 'المجادلة والظهار',
    },
    59: {
      'name': 'الحشر',
      'type': 'مدنية',
      'description': 'سبي بني النضير والهجرة',
    },
    60: {
      'name': 'الممتحنة',
      'type': 'مدنية',
      'description': 'امتحان المؤمنات والموالاة',
    },
    61: {'name': 'الصف', 'type': 'مدنية', 'description': 'صف المؤمنين وعيسى'},
    62: {
      'name': 'الجمعة',
      'type': 'مدنية',
      'description': 'يوم الجمعة وصلاة الجمعة',
    },
    63: {'name': 'المنافقون', 'type': 'مدنية', 'description': 'صفات المنافقين'},
    64: {'name': 'التغابن', 'type': 'مدنية', 'description': 'التغابن والإيمان'},
    65: {
      'name': 'الطلاق',
      'type': 'مدنية',
      'description': 'أحكام الطلاق والعدة',
    },
    66: {
      'name': 'التحريم',
      'type': 'مدنية',
      'description': 'التحريم والاستغفار',
    },
    67: {
      'name': 'الملك',
      'type': 'مكية',
      'description': 'ملك الله والموت والحياة',
    },
    68: {
      'name': 'القلم',
      'type': 'مكية',
      'description': 'القلم والأمانة والكتابة',
    },
    69: {
      'name': 'الحاقة',
      'type': 'مكية',
      'description': 'الحاقة ويوم القيامة',
    },
    70: {
      'name': 'المعارج',
      'type': 'مكية',
      'description': 'معارج الصعود والصلاة',
    },
    71: {'name': 'نوح', 'type': 'مكية', 'description': 'دعاء نوح لابنه'},
    72: {'name': 'الجن', 'type': 'مكية', 'description': 'الجن والقرآن العجيب'},
    73: {'name': 'المزمل', 'type': 'مكية', 'description': 'قم الليل والتهجد'},
    74: {'name': 'المدثر', 'type': 'مكية', 'description': 'قم فأنذر والتكوير'},
    75: {
      'name': 'القيامة',
      'type': 'مكية',
      'description': 'القيامة وتفصيل الأجسام',
    },
    76: {
      'name': 'الإنسان',
      'type': 'مدنية',
      'description': 'الإنسان والكافرون',
    },
    77: {
      'name': 'المرسلات',
      'type': 'مكية',
      'description': 'المرسلات والويل يومئذ',
    },
    78: {
      'name': 'النبأ',
      'type': 'مكية',
      'description': 'النبأ العظيم والنفخ في الصور',
    },
    79: {
      'name': 'النازعات',
      'type': 'مكية',
      'description': 'النازعات غرقاً ونشراً',
    },
    80: {'name': 'عبس', 'type': 'مكية', 'description': 'عبس وتولى عن الأعمى'},
    81: {
      'name': 'التكوير',
      'type': 'مكية',
      'description': 'التكوير والنجوم انكدرت',
    },
    82: {
      'name': 'الانفطار',
      'type': 'مكية',
      'description': 'الانفطار والكواكب انتثرت',
    },
    83: {
      'name': 'المطففين',
      'type': 'مكية',
      'description': 'ويل للمطففين والكافرين',
    },
    84: {
      'name': 'الانشقاق',
      'type': 'مكية',
      'description': 'الانشقاق والتصادق',
    },
    85: {
      'name': 'البروج',
      'type': 'مكية',
      'description': 'البروج والأخدود والنار',
    },
    86: {
      'name': 'الطارق',
      'type': 'مكية',
      'description': 'الطارق والنجم الثاقب',
    },
    87: {'name': 'الأعلى', 'type': 'مكية', 'description': 'سبح اسم ربك الأعلى'},
    88: {
      'name': 'الغاشية',
      'type': 'مكية',
      'description': 'الغاشية وأشقياء سعاة',
    },
    89: {
      'name': 'الفجر',
      'type': 'مكية',
      'description': 'الفجر وليالٍ عشر وعاد وإرم',
    },
    90: {'name': 'البلد', 'type': 'مكية', 'description': 'البلد والأم الشقق'},
    91: {'name': 'الشمس', 'type': 'مكية', 'description': 'الشمس والقمر والليل'},
    92: {
      'name': 'الليل',
      'type': 'مكية',
      'description': 'الليل والنهار والجزاء',
    },
    93: {'name': 'الضحى', 'type': 'مكية', 'description': 'الضحى والليل والوعد'},
    94: {'name': 'الشرح', 'type': 'مكية', 'description': 'انشرح صدرك والرفع'},
    95: {
      'name': 'التين',
      'type': 'مكية',
      'description': 'التين والزيتون وسينين',
    },
    96: {
      'name': 'العلق',
      'type': 'مكية',
      'description': 'أول ما نزل من القرآن',
    },
    97: {
      'name': 'القدر',
      'type': 'مكية',
      'description': 'ليلة القدر خير من ألف شهر',
    },
    98: {
      'name': 'البينة',
      'type': 'مدنية',
      'description': 'البينة والكافرون من أهل الكتاب',
    },
    99: {
      'name': 'الزلزلة',
      'type': 'مدنية',
      'description': 'الزلزلة والأرض أخرجت أثقالها',
    },
    100: {
      'name': 'العاديات',
      'type': 'مكية',
      'description': 'العاديات والإنسان حب المال',
    },
    101: {
      'name': 'القارعة',
      'type': 'مكية',
      'description': 'القارعة والكافرون خفاف',
    },
    102: {'name': 'التكاثر', 'type': 'مكية', 'description': 'التكاثر والحاقة'},
    103: {
      'name': 'العصر',
      'type': 'مكية',
      'description': 'والعصر إن الإنسان لفي خسر',
    },
    104: {'name': 'الهمزة', 'type': 'مكية', 'description': 'ويل لكل همزة لمزة'},
    105: {
      'name': 'الفيل',
      'type': 'مكية',
      'description': 'ألم تر كيف فعل ربك بأصحاب الفيل',
    },
    106: {
      'name': 'قريش',
      'type': 'مكية',
      'description': 'لإيلاف قريش رحل الشتاء والصيف',
    },
    107: {
      'name': 'الماعون',
      'type': 'مكية',
      'description': 'أرأيت الذي يكذب بالدين',
    },
    108: {
      'name': 'الكوثر',
      'type': 'مكية',
      'description': 'إنا أعطيناك الكوثر فصل لربك',
    },
    109: {
      'name': 'الكافرون',
      'type': 'مكية',
      'description': 'قل يا أيها الكافرون',
    },
    110: {
      'name': 'النصر',
      'type': 'مدنية',
      'description': 'إذا جاء نصر الله والفتح',
    },
    111: {
      'name': 'المسد',
      'type': 'مكية',
      'description': 'تبت يدا أبي لهب وتب',
    },
    112: {
      'name': 'الإخلاص',
      'type': 'مكية',
      'description': 'توحيد الله ونفي الشرك',
    },
    113: {
      'name': 'الفلق',
      'type': 'مكية',
      'description': 'الاستعاذة من شرور الليل',
    },
    114: {
      'name': 'الناس',
      'type': 'مكية',
      'description': 'الاستعاذة من شر الوسواس الخناس',
    },
  };

  // الحصول على تفسير السورة
  static List<Map<String, String>> getTafsirForSurah(int surahNumber) {
    // محاولة الحصول على البيانات من quran_pak أولاً
    final quranPakService = QuranPakService();
    final quranPakData = quranPakService.getTafsirForSurah(surahNumber);

    if (quranPakData != null) {
      return _convertQuranPakDataToTafsirFormat(surahNumber, quranPakData);
    }

    // إذا كان التفسير التفصيلي موجوداً، نرجعه
    if (tafsirBySurah.containsKey(surahNumber)) {
      return tafsirBySurah[surahNumber]!;
    }

    // إلا نولد تفسيراً لجميع آيات السورة
    final verseCount = quran.getVerseCount(surahNumber);
    final surahName = quran.getSurahNameArabic(surahNumber);
    final info = surahInfo[surahNumber];

    List<Map<String, String>> result = [];

    // إضافة مقدمة السورة أولاً
    result.add({
      'ayah': '0',
      'text': 'سورة $surahName',
      'tafsir':
          info?['description'] ??
          'سورة ${info?['type'] ?? ''} رقم $surahNumber',
    });

    // إضافة تفسير لكل آية
    for (int i = 1; i <= verseCount; i++) {
      final verseText = quran.getVerse(surahNumber, i);
      result.add({
        'ayah': '$i',
        'text': verseText,
        'tafsir': _generateTafsir(surahNumber, i, verseText),
      });
    }

    return result;
  }

  static Future<List<Map<String, String>>> getMuyassarTafsirForSurah(
    int surahNumber,
  ) async {
    final service = TafsirApiService();
    final versesMap = await service.fetchMuyassarVersesMap(surahNumber);

    final surahName = quran.getSurahNameArabic(surahNumber);
    final info = surahInfo[surahNumber];

    final List<Map<String, String>> result = [];

    result.add({
      'ayah': '0',
      'text': 'سورة $surahName',
      'tafsir':
          info?['description'] ??
          'سورة ${info?['type'] ?? ''} رقم $surahNumber',
    });

    final verseCount = quran.getVerseCount(surahNumber);
    int startVerse = 1;
    while (startVerse <= verseCount) {
      final currentTafsir = versesMap[startVerse] ?? '';
      int endVerse = startVerse;

      // تجميع الآيات التي تشترك في نفس التفسير (إذا لم يكن فارغاً)
      if (currentTafsir.isNotEmpty) {
        while (endVerse + 1 <= verseCount &&
            (versesMap[endVerse + 1] ?? '') == currentTafsir) {
          endVerse++;
        }
      }

      StringBuffer groupedText = StringBuffer();
      for (int i = startVerse; i <= endVerse; i++) {
        final verseText = quran.getVerse(surahNumber, i);
        groupedText.write(verseText);
        // إضافة رقم الآية في قوسين بعد كل آية في المجموعة
        groupedText.write(" ($i) ");
      }

      result.add({
        'ayah': startVerse == endVerse
            ? '$startVerse'
            : '$startVerse-$endVerse',
        'text': groupedText.toString().trim(),
        'tafsir': currentTafsir,
      });

      startVerse = endVerse + 1;
    }

    return result;
  }

  // تحويل بيانات quran_pak إلى صيغة TafsirData
  static List<Map<String, String>> _convertQuranPakDataToTafsirFormat(
    int surahNumber,
    Map<String, dynamic> quranPakData,
  ) {
    List<Map<String, String>> result = [];
    final surahName = quran.getSurahNameArabic(surahNumber);
    final info = surahInfo[surahNumber];

    // إضافة مقدمة السورة
    result.add({
      'ayah': '0',
      'text': 'سورة $surahName',
      'tafsir':
          info?['description'] ??
          'سورة ${info?['type'] ?? ''} رقم $surahNumber',
    });

    // إضافة تفسير من quran_pak لكل آية مع تجميع المتشابه
    final verses = quranPakData['verses'] as Map<int, Map<String, dynamic>>?;
    if (verses != null) {
      final sortedVerseNums = verses.keys.toList()..sort();
      final Map<int, String> interpretationMap = {};
      for (final vn in sortedVerseNums) {
        interpretationMap[vn] =
            verses[vn]?['interpretation']?.toString() ??
            verses[vn]?['tafsir']?.toString() ??
            '';
      }

      int start = 0;
      while (start < sortedVerseNums.length) {
        final currentAyahNum = sortedVerseNums[start];
        final currentTafsir = interpretationMap[currentAyahNum] ?? '';
        int end = start;

        if (currentTafsir.isNotEmpty) {
          while (end + 1 < sortedVerseNums.length &&
              interpretationMap[sortedVerseNums[end + 1]] == currentTafsir) {
            end++;
          }
        }

        StringBuffer groupedText = StringBuffer();
        for (int i = start; i <= end; i++) {
          final vn = sortedVerseNums[i];
          final text = verses[vn]?['text']?.toString() ?? '';
          groupedText.write(text);
          groupedText.write(" ($vn) ");
        }

        result.add({
          'ayah': start == end
              ? '$currentAyahNum'
              : '$currentAyahNum-${sortedVerseNums[end]}',
          'text': groupedText.toString().trim(),
          'tafsir': currentTafsir.isEmpty
              ? 'لا يوجد تفسير متاح'
              : currentTafsir,
        });

        start = end + 1;
      }
    }

    return result;
  }

  // توليد تفسير مبسط للآية
  static String _generateTafsir(
    int surahNumber,
    int ayahNumber,
    String verseText,
  ) {
    // هنا يمكن إضافة تفسيرات مخصصة لآيات معروفة
    // حالياً نعيد تفسيراً عاماً

    final info = surahInfo[surahNumber];
    if (info != null) {
      return 'آية $ayahNumber من سورة ${info['name']} (${info['type']}). ${verseText.substring(0, verseText.length > 30 ? 30 : verseText.length)}...';
    }

    return 'آية $ayahNumber من سورة رقم $surahNumber. اضغط للقراءة والتدبر.';
  }

  // قائمة السور المتوفرة في التفسير (الآن جميع السور متوفرة)
  static List<int> getAvailableSurahs() {
    return List<int>.generate(114, (i) => i + 1);
  }
}
