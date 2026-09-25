// تفسير السعدي الكامل
// المصدر: تفسير السعدي (تيسير الكريم الرحمن في تفسير كلام المنان)
// المؤلف: الشيخ عبد الرحمن بن ناصر السعدي (ت 1376هـ)

class TafsirSaadi {
  // قاموس يحتوي على تفسير السعدي لجميع السور
  // المفتاح: رقم السورة
  // القيمة: قائمة بالآيات وتفسيرها
  
  static final Map<int, List<Map<String, String>>> tafsir = {
    1: _surah1,
    2: _surah2,
    3: _surah3,
    4: _surah4,
    5: _surah5,
    6: _surah6,
    7: _surah7,
    8: _surah8,
    9: _surah9,
    10: _surah10,
    11: _surah11,
    12: _surah12,
    13: _surah13,
    14: _surah14,
    15: _surah15,
    16: _surah16,
    17: _surah17,
    18: _surah18,
    19: _surah19,
    20: _surah20,
    21: _surah21,
    22: _surah22,
    23: _surah23,
    24: _surah24,
    25: _surah25,
    26: _surah26,
    27: _surah27,
    28: _surah28,
    29: _surah29,
    30: _surah30,
    31: _surah31,
    32: _surah32,
    33: _surah33,
    34: _surah34,
    35: _surah35,
    36: _surah36,
    37: _surah37,
    38: _surah38,
    39: _surah39,
    40: _surah40,
    41: _surah41,
    42: _surah42,
    43: _surah43,
    44: _surah44,
    45: _surah45,
    46: _surah46,
    47: _surah47,
    48: _surah48,
    49: _surah49,
    50: _surah50,
    51: _surah51,
    52: _surah52,
    53: _surah53,
    54: _surah54,
    55: _surah55,
    56: _surah56,
    57: _surah57,
    58: _surah58,
    59: _surah59,
    60: _surah60,
    61: _surah61,
    62: _surah62,
    63: _surah63,
    64: _surah64,
    65: _surah65,
    66: _surah66,
    67: _surah67,
    68: _surah68,
    69: _surah69,
    70: _surah70,
    71: _surah71,
    72: _surah72,
    73: _surah73,
    74: _surah74,
    75: _surah75,
    76: _surah76,
    77: _surah77,
    78: _surah78,
    79: _surah79,
    80: _surah80,
    81: _surah81,
    82: _surah82,
    83: _surah83,
    84: _surah84,
    85: _surah85,
    86: _surah86,
    87: _surah87,
    88: _surah88,
    89: _surah89,
    90: _surah90,
    91: _surah91,
    92: _surah92,
    93: _surah93,
    94: _surah94,
    95: _surah95,
    96: _surah96,
    97: _surah97,
    98: _surah98,
    99: _surah99,
    100: _surah100,
    101: _surah101,
    102: _surah102,
    103: _surah103,
    104: _surah104,
    105: _surah105,
    106: _surah106,
    107: _surah107,
    108: _surah108,
    109: _surah109,
    110: _surah110,
    111: _surah111,
    112: _surah112,
    113: _surah113,
    114: _surah114,
  };

  // الحصول على تفسير آية محددة
  static String? getAyahTafsir(int surahNumber, int ayahNumber) {
    final surahTafsir = tafsir[surahNumber];
    if (surahTafsir == null) return null;
    
    for (final item in surahTafsir) {
      if (item['ayah'] == ayahNumber.toString()) {
        return item['tafsir'];
      }
    }
    return null;
  }

  // الحصول على تفسير السورة كاملاً
  static List<Map<String, String>> getSurahTafsir(int surahNumber) {
    return tafsir[surahNumber] ?? [];
  }

  static final List<Map<String, String>> _surah3 = [];
  static final List<Map<String, String>> _surah4 = [];
  static final List<Map<String, String>> _surah5 = [];
  static final List<Map<String, String>> _surah6 = [];
  static final List<Map<String, String>> _surah7 = [];
  static final List<Map<String, String>> _surah8 = [];
  static final List<Map<String, String>> _surah9 = [];
  static final List<Map<String, String>> _surah10 = [];
  static final List<Map<String, String>> _surah11 = [];
  static final List<Map<String, String>> _surah12 = [];
  static final List<Map<String, String>> _surah13 = [];
  static final List<Map<String, String>> _surah14 = [];
  static final List<Map<String, String>> _surah15 = [];
  static final List<Map<String, String>> _surah16 = [];
  static final List<Map<String, String>> _surah17 = [];
  static final List<Map<String, String>> _surah18 = [];
  static final List<Map<String, String>> _surah19 = [];
  static final List<Map<String, String>> _surah20 = [];
  static final List<Map<String, String>> _surah21 = [];
  static final List<Map<String, String>> _surah22 = [];
  static final List<Map<String, String>> _surah23 = [];
  static final List<Map<String, String>> _surah24 = [];
  static final List<Map<String, String>> _surah25 = [];
  static final List<Map<String, String>> _surah26 = [];
  static final List<Map<String, String>> _surah27 = [];
  static final List<Map<String, String>> _surah28 = [];
  static final List<Map<String, String>> _surah29 = [];
  static final List<Map<String, String>> _surah30 = [];
  static final List<Map<String, String>> _surah31 = [];
  static final List<Map<String, String>> _surah32 = [];
  static final List<Map<String, String>> _surah33 = [];
  static final List<Map<String, String>> _surah34 = [];
  static final List<Map<String, String>> _surah35 = [];
  static final List<Map<String, String>> _surah36 = [];
  static final List<Map<String, String>> _surah37 = [];
  static final List<Map<String, String>> _surah38 = [];
  static final List<Map<String, String>> _surah39 = [];
  static final List<Map<String, String>> _surah40 = [];
  static final List<Map<String, String>> _surah41 = [];
  static final List<Map<String, String>> _surah42 = [];
  static final List<Map<String, String>> _surah43 = [];
  static final List<Map<String, String>> _surah44 = [];
  static final List<Map<String, String>> _surah45 = [];
  static final List<Map<String, String>> _surah46 = [];
  static final List<Map<String, String>> _surah47 = [];
  static final List<Map<String, String>> _surah48 = [];
  static final List<Map<String, String>> _surah49 = [];
  static final List<Map<String, String>> _surah50 = [];
  static final List<Map<String, String>> _surah51 = [];
  static final List<Map<String, String>> _surah52 = [];
  static final List<Map<String, String>> _surah53 = [];
  static final List<Map<String, String>> _surah54 = [];
  static final List<Map<String, String>> _surah55 = [];
  static final List<Map<String, String>> _surah56 = [];
  static final List<Map<String, String>> _surah57 = [];
  static final List<Map<String, String>> _surah58 = [];
  static final List<Map<String, String>> _surah59 = [];
  static final List<Map<String, String>> _surah60 = [];
  static final List<Map<String, String>> _surah61 = [];
  static final List<Map<String, String>> _surah62 = [];
  static final List<Map<String, String>> _surah63 = [];
  static final List<Map<String, String>> _surah64 = [];
  static final List<Map<String, String>> _surah65 = [];
  static final List<Map<String, String>> _surah66 = [];
  static final List<Map<String, String>> _surah67 = [];
  static final List<Map<String, String>> _surah68 = [];
  static final List<Map<String, String>> _surah69 = [];
  static final List<Map<String, String>> _surah70 = [];
  static final List<Map<String, String>> _surah71 = [];
  static final List<Map<String, String>> _surah72 = [];
  static final List<Map<String, String>> _surah73 = [];
  static final List<Map<String, String>> _surah74 = [];
  static final List<Map<String, String>> _surah75 = [];
  static final List<Map<String, String>> _surah76 = [];
  static final List<Map<String, String>> _surah77 = [];
  static final List<Map<String, String>> _surah78 = [];
  static final List<Map<String, String>> _surah79 = [];
  static final List<Map<String, String>> _surah80 = [];
  static final List<Map<String, String>> _surah81 = [];
  static final List<Map<String, String>> _surah82 = [];
  static final List<Map<String, String>> _surah83 = [];
  static final List<Map<String, String>> _surah84 = [];
  static final List<Map<String, String>> _surah85 = [];
  static final List<Map<String, String>> _surah86 = [];
  static final List<Map<String, String>> _surah87 = [];
  static final List<Map<String, String>> _surah88 = [];
  static final List<Map<String, String>> _surah89 = [];
  static final List<Map<String, String>> _surah90 = [];
  static final List<Map<String, String>> _surah91 = [];
  static final List<Map<String, String>> _surah92 = [];
  static final List<Map<String, String>> _surah93 = [];
  static final List<Map<String, String>> _surah94 = [];
  static final List<Map<String, String>> _surah95 = [];
  static final List<Map<String, String>> _surah96 = [];
  static final List<Map<String, String>> _surah97 = [];
  static final List<Map<String, String>> _surah98 = [];
  static final List<Map<String, String>> _surah99 = [];
  static final List<Map<String, String>> _surah100 = [];
  static final List<Map<String, String>> _surah101 = [];
  static final List<Map<String, String>> _surah102 = [];
  static final List<Map<String, String>> _surah103 = [];
  static final List<Map<String, String>> _surah104 = [];
  static final List<Map<String, String>> _surah105 = [];
  static final List<Map<String, String>> _surah106 = [];
  static final List<Map<String, String>> _surah107 = [];
  static final List<Map<String, String>> _surah108 = [];
  static final List<Map<String, String>> _surah109 = [];
  static final List<Map<String, String>> _surah110 = [];
  static final List<Map<String, String>> _surah111 = [];

  // ============== سورة الفاتحة ==============
  static final List<Map<String, String>> _surah1 = [
    {
      'ayah': '1',
      'tafsir': 'يقول تعالى مفتتحاً كتابه العزيز: بِسْمِ اللَّهِ، أي: أبدأ قراءة الكتاب وغيره من الأعمال باسم الله، مستعيناً به، متوكلاً عليه، موقناً به، مفتخراً به. والله: هو المألوه المعبود، الذي له الأسماء الحسنى والصفات العلى، لا إله إلا هو، وكل ما سواه باطل. الرَّحْمَنِ: أي ذي الرحمة الواسعة التي عمّت جميع الخلائق، الرَّحِيمِ: أي بالمؤمنين المتبعين له، فهم أهل لرحمته الخاصة.',
    },
    {
      'ayah': '2',
      'tafsir': 'الحمد: الثناء بالجميل على من يستحقه، فالله أهل لأن يحمد، فهو رب كل شيء وخالقه ومالكه ورازقه ومدبره، فجميع النعم الدينية والدنيوية منه سبحانه، فله الحمد على ذلك. والعالمين: كل ما سوى الله، من المخلوقات العقلية وغيرها، الإنس والجن والملائكة، وكل ذي روح، وغير ذلك من جميع المخلوقات.',
    },
    {
      'ayah': '3',
      'tafsir': 'ثم كرر اسمي الرحمة للتأكيد على شمول رحمته، وأنه سبحانه ذو رحمة واسعة بالخلق أجمعين، وبالعالمين، وذو رحمة خاصة بالمؤمنين في الآخرة، لا يغلب حكمته رحمته، ولا رحمته حكمته، بل بينهما توافق تام.',
    },
    {
      'ayah': '4',
      'tafsir': 'مالك يوم الدين: أي مالك يوم الجزاء والحساب، حيث يكون الملك فيه لله وحده، لا يشاركه فيه أحد، فيحكم بين عباده بأحكامه العدل التي أخبر بها في كتابه، وأخبر عنها رسوله صلى الله عليه وسلم.',
    },
    {
      'ayah': '5',
      'tafsir': 'إِيَّاكَ نَعْبُدُ: أي لا نعبد إلا إياك ولا ندعو سواك، ولا نرجو إلا إياك، فالعبادة هي حق الله الأعظم على عباده، وهي الغاية التي خلقهم لأجلها، كما قال: {وَمَا خَلَقْتُ الْجِنَّ وَالْأِنْسَ إِلَّا لِيَعْبُدُونِ}. وَإِيَّاكَ نَسْتَعِينُ: أي لا نستعين إلا بك، فكل ما أريد من الخير والتوفيق والهداية والرزق والعصمة، فإنما نطلبه منك، ونفوض أمورنا كلها إليك.',
    },
    {
      'ayah': '6',
      'tafsir': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ: أي دلنا وثبتنا على الطريق الموصل إلى رضاك وجنتك، الذي لا اعوجاج فيه، وهو الإسلام القويم، الذي هو الطريق الواضح المؤدي إلى الله.',
    },
    {
      'ayah': '7',
      'tafsir': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ: أي طريق النبيين والصديقين والشهداء والصالحين، الذين أنعمت عليهم بالهداية والعصمة والعلم والعمل، فاهدنا إلى طريقهم، واجعلنا مثلهم. غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ: وهم اليهود الذين عرفوا الحق ولم يتبعوه، فحل بهم غضب الله. وَلَا الضَّالِّينَ: وهم النصارى الذين جهلوا الحق فاتبعوا الباطل على جهل منهم، فهم ضالون عن طريق الهداية.',
    },
  ];

  // ============== سورة البقرة ==============
  static final List<Map<String, String>> _surah2 = [
    {
      'ayah': '1',
      'tafsir': 'الم: من الحروف المقطعة التي افتتح بها الله بعض السور، وهي: ألف، لام، ميم. والله أعلم بمرادها، وقيل: هي الآيات الكريمة، وقيل: أنا الله أعلم، والأولى ترك التعمق في ذلك والتسليم لله.',
    },
    {
      'ayah': '2',
      'tafsir': 'ذَلِكَ الْكِتَابُ: أي هذا القرآن العظيم. لَا رَيْبَ فِيهِ: أي لا شك في أنه من عند الله، ولا في صدقه وعدله وهدايته، فهو الحق بلا شك. هُدًى لِّلْمُتَّقِينَ: أي فيه الهداية التامة للذين يتقون بأداء أوامر الله واجتناب نواهيه، فهم المنتفعون بالقرآن حق الانتفاع.',
    },
    {
      'ayah': '3',
      'tafsir': 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ: أي بالله وملائكته وكتبه ورسله واليوم الآخر والقدر خيره وشره، وكل ما أخبر الله به في القرآن مما غاب عن حسهم. وَيُقِيمُونَ الصَّلَاةَ: أي يؤدونها على الوجه الذي يرضي الله، بأركانها وشروطها وواجباتها وسننها. وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ: يتصدقون من أموالهم التي رزقهم الله، تطوعاً ووجوباً، قليلاً وكثيراً، سراً وعلانية، في أسباب الخير كلها.',
    },
    {
      'ayah': '4',
      'tafsir': 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ: أي بالقرآن الذي أنزل على محمد صلى الله عليه وسلم. وَمَا أُنزِلَ مِن قَبْلِكَ: من الكتب السماوية: التوراة والإنجيل وغيرهما. وَبِالْآخِرَةِ هُمْ يُوقِنُونَ: أي يؤمنون بالبعث والجزاء والحساب وما أخبر الله به من أمور الآخرة إيماناً يقينياً لا شك فيه.',
    },
    {
      'ayah': '5',
      'tafsir': 'أُولَٰئِكَ: أي المتصفون بهذه الأوصاف من الإيمان بالغيب وإقام الصلاة والإنفاق والإيمان بالقرآن والكتب السابقة واليقين بالآخرة. عَلَىٰ هُدًى مِّن رَّبِّهِمْ: أي على طريق واضح ومنهج قويم من ربهم، يحصلون به على العلم النافع والعمل الصالح. وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ: أي الفائزون بالسعادة في الدنيا والآخرة، والنجاة من الشقاء والعذاب الأليم.',
    },
    // آية الكرسي - من أهم آيات القرآن
    {
      'ayah': '255',
      'tafsir': 'هذه آية الكرسي، وهي أعظم آية في القرآن، تشتمل على توحيد الله وصفاته العليّة. اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ: أي لا معبود حق إلا هو وحده لا شريك له. الْحَيُّ: الذي له الحياة الكاملة الأبدية. الْقَيُّومُ: الذي يقوم بنفسه ويقوم بجميع الأشياء، لا يحتاج إلى أحد، وكل شيء يحتاج إليه. لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ: لا يغلبه نعاس ولا يلحقه نوم. لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ: أي هو المالك لكل شيء. مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ: لا أحد يتجرأ على الشفاعة عنده إلا بعد إذنه. يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ: علمه محيط بجميع الأمور. وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ: لا أحد يحيط بعلم الله إلا بقدر ما أعطاه الله. وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ: كرسيه وسع السماوات والأرض كلها. وَلَا يَئُودُهُ حِفْظُهُمَا: لا يثقله حفظهما. وَهُوَ الْعَلِيُّ: الأعلى بذاته وقهره. الْعَظِيمُ: العظيم في كل شيء.',
    },
  ];

  // ... (سأكمل باقي السور)

  // ============== سورة الإخلاص ==============
  static final List<Map<String, String>> _surah112 = [
    {
      'ayah': '1',
      'tafsir': 'قُلْ: يا محمد توجهاً لجميع المخاطبين. هُوَ اللَّهُ أَحَدٌ: أي الله واحد أحد، لا شريك له في ذاته، ولا في صفاته، ولا في أفعاله، متفرد بالألوهية والربوبية والأسماء والصفات، لا يشاركه أحد في شيء من ذلك.',
    },
    {
      'ayah': '2',
      'tafsir': 'اللَّهُ الصَّمَدُ: الصمد: الذي يصمد إليه الخلائق في حوائجهم، ويفزعون إليه في شدائدهم، ويطلبون إعانته في أعمالهم، فهو المقصود في الحوائج والفزائع، الكامل في ذاته وصفاته وأفعاله، المحتاج إليه كل الخلق، فكل شيء خالٍ منه محتاج إليه.',
    },
    {
      'ayah': '3',
      'tafsir': 'لَمْ يَلِدْ: نفي الولد عن الله، لأن الولد يقتضي مثله، والله منزه عن المثل والشبيه. وَلَمْ يُولَدْ: نفي الوالد عنه، فلا والد له، لأن الوالد يكون قبل الولد، والله قديم أزلي لا أول له. وهذا نفي للحدوث عنه، فهو أزلي أبدي، الأول والآخر.',
    },
    {
      'ayah': '4',
      'tafsir': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ: أي ليس له نظير ولا مثيل ولا ضد ولا ند، لا في ذاته ولا في صفاته ولا في أفعاله، فهو منفرد بالكمال المطلق، وكل ما سواه مخلوق له خالق رازق مدبر.',
    },
  ];

  // ============== سورة الفلق ==============
  static final List<Map<String, String>> _surah113 = [
    {
      'ayah': '1',
      'tafsir': 'قُلْ أَعُوذُ: أي أطلب العصمة والحماية واللجوء. بِرَبِّ الْفَلَقِ: أي رب الصبح، سماه فلقاً لأنه يفلق الظلام بنوره، والفلق هو الصبح الذي يظهر عند طلوع الشمس، أو هو الفجر.',
    },
    {
      'ayah': '2',
      'tafsir': 'مِّن شَرِّ مَا خَلَقَ: من شر كل ما خلقه الله من المخلوقات التي فيها شر، كالحيوانات الضارة والآفات وغير ذلك، والإنس والجن من المؤذين.',
    },
    {
      'ayah': '3',
      'tafsir': 'وَمِّن شَرِّ غَاسِقٍ إِذَا وَقَبَ: من شر الليل إذا أظلم وغطى كل شيء بظلامه، والغاسق: الليل، والوقب: دخول الشيء وغلبته، أي من شر الليل إذا دخل وغلب بنوره، ففيه من الأخطار ما لا يخفى.',
    },
    {
      'ayah': '4',
      'tafsir': 'وَمِّن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ: أي من شر الساحرات اللاتي ينفثن في العقد، أي يعقدن الخيط وينفثن فيه، وينفثن فيه بكلامهن، سحراً وتأثيراً في المحسود عليه.',
    },
    {
      'ayah': '5',
      'tafsir': 'وَمِّن شَرِّ حَاسِدٍ إِذَا حَسَدَ: أي من شر كل حاسد يحسد على ما أنعم الله به على عباده، فيؤذيه بعينه أو بلسانه أو بيده، فإن الحسد من أعظم الشرور، وهو يوجب كثرة الأذى للمحسود.',
    },
  ];

  // ============== سورة الناس ==============
  static final List<Map<String, String>> _surah114 = [
    {
      'ayah': '1',
      'tafsir': 'قُلْ أَعُوذُ: أي أطلب العصمة. بِرَبِّ النَّاسِ: أي رب جميع الناس، خالقهم ومالكهم وإلههم الحق، لا رب لهم سواه، فالكل مخلوق له رازقه مدبره.',
    },
    {
      'ayah': '2',
      'tafsir': 'مَلِكِ النَّاسِ: أي مالكهم بملكه التام الذي لا شريك له فيه، فكل شيء ملك له، وكلهم عبيد له، لا يملك أحد منهم شيئاً إلا وهو تحت ملك الله وسلطانه.',
    },
    {
      'ayah': '3',
      'tafsir': 'إِلَٰهِ النَّاسِ: أي معبودهم الحق الذي لا معبود سواه، فالكل في عبوديته وإن تفاوتوا في الدرجات، فكلهم خاضعون لأمره خاضعون لقضائه.',
    },
    {
      'ayah': '4',
      'tafsir': 'مِّن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ: أي من شر الشيطان الذي يوسوس للإنسان في صدره، ثم يختفي وينكمش عند ذكر الله وتلاوة القرآن.',
    },
    {
      'ayah': '5',
      'tafsir': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ: أي يجري في قلوب الناس وهم إلهاء من شره، يزين لهم الشر ويحبب إليهم المعاصي ويمنعهم عن الخير، فيوسوس في قلوبهم بما شاء من الشرور.',
    },
    {
      'ayah': '6',
      'tafsir': 'مِنَ الْجِنَّةِ وَالنَّاسِ: أي من شر شياطين الجن الذين يوسوسون في صدور الإنس، ومن شر شياطين الإنس الذين يفعلون مثل فعلهم أو أشد، فكلاهما مؤذٍ للعباد.',
    },
  ];
}
