import 'package:flutter/material.dart';

/// نموذج الذكر
class AzkarItem {
  final String id;
  final String text;
  final String? translation;
  final String? reference;
  final int count;
  final String? fadl; // فضل الذكر

  const AzkarItem({
    required this.id,
    required this.text,
    this.translation,
    this.reference,
    this.count = 1,
    this.fadl,
  });
}

/// نموذج فئة الأذكار
class AzkarCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<AzkarItem> items;

  const AzkarCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
  });
}

/// بيانات الأذكار من حصن المسلم
class AzkarData {
  static final List<AzkarCategory> categories = [
    _morningAzkar,
    _eveningAzkar,
    _afterPrayerAzkar,
    _sleepAzkar,
    _wakingAzkar,
    _mosqueAzkar,
    _eatingAzkar,
    _travelAzkar,
    _ruqyaAzkar,
  ];

  /// أذكار الصباح
  static final AzkarCategory _morningAzkar = AzkarCategory(
    id: 'morning',
    title: 'أذكار الصباح',
    subtitle: 'من طلوع الشمس إلى الزوال',
    icon: Icons.wb_sunny,
    color: const Color(0xFFFFA726),
    items: [
      AzkarItem(
        id: 'morning_1',
        text: 'آية الكرسي',
        translation: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
        reference: 'البقرة 255',
        fadl: 'من قالها حين يصبح أجير من الجن حتى يمسي، ومن قالها حين يمسي أجير من الجن حتى يصبح',
        count: 1,
      ),
      AzkarItem(
        id: 'morning_2',
        text: 'سورة الإخلاص',
        translation: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        reference: 'رواه البخاري',
        fadl: 'تعدل ثلث القرآن',
        count: 3,
      ),
      AzkarItem(
        id: 'morning_3',
        text: 'سورة الفلق',
        translation: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        reference: 'رواه البخاري',
        count: 3,
      ),
      AzkarItem(
        id: 'morning_4',
        text: 'سورة الناس',
        translation: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
        reference: 'رواه البخاري',
        count: 3,
      ),
      AzkarItem(
        id: 'morning_5',
        text: 'أصبحنا وأصبح الملك لله',
        translation: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        reference: 'رواه مسلم',
        fadl: 'من قالها موقناً بها حين يمسي ومات من ليلته دخل الجنة',
        count: 1,
      ),
      AzkarItem(
        id: 'morning_6',
        text: 'اللهم بك أصبحنا',
        translation: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
        reference: 'رواه الترمذي',
        count: 1,
      ),
      AzkarItem(
        id: 'morning_7',
        text: 'اللهم ما أصبح بي',
        translation: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
        reference: 'رواه أبو داود',
        count: 1,
      ),
      AzkarItem(
        id: 'morning_8',
        text: 'اللهم عافني',
        translation: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
        reference: 'رواه أبو داود',
        count: 3,
      ),
      AzkarItem(
        id: 'morning_9',
        text: 'حسبي الله',
        translation: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        reference: 'رواه أبو داود',
        fadl: 'من قالها حين يصبح وحين يمسي سبع مرات كفاه الله ما أهمه',
        count: 7,
      ),
      AzkarItem(
        id: 'morning_10',
        text: 'سبحان الله وبحمده',
        translation: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        reference: 'رواه مسلم',
        fadl: 'من قالها مئة مرة غفرت له ذنوبه ولو كانت مثل زبد البحر',
        count: 100,
      ),
    ],
  );

  /// أذكار المساء
  static final AzkarCategory _eveningAzkar = AzkarCategory(
    id: 'evening',
    title: 'أذكار المساء',
    subtitle: 'من العصر إلى المغرب',
    icon: Icons.nights_stay,
    color: const Color(0xFF5C6BC0),
    items: [
      AzkarItem(
        id: 'evening_1',
        text: 'آية الكرسي',
        translation: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
        reference: 'البقرة 255',
        fadl: 'من قالها حين يمسي أجير من الجن حتى يصبح',
        count: 1,
      ),
      AzkarItem(
        id: 'evening_2',
        text: 'أمسينا وأمسى الملك لله',
        translation: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'evening_3',
        text: 'اللهم بك أمسينا',
        translation: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
        reference: 'رواه الترمذي',
        count: 1,
      ),
      AzkarItem(
        id: 'evening_4',
        text: 'أعوذ بكلمات الله التامات',
        translation: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        reference: 'رواه مسلم',
        fadl: 'من قالها حين يمسي ثلاث مرات لم يضره سامٌ ولا سحر',
        count: 3,
      ),
      AzkarItem(
        id: 'evening_5',
        text: 'اللهم إني أسألك خير هذا الليلة',
        translation: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذِهِ اللَّيْلَةِ، فَتْحَهَا وَنَصْرَهَا وَنُورَهَا وَبَرَكَتَهَا وَهُدَاهَا',
        reference: 'رواه مسلم',
        count: 1,
      ),
    ],
  );

  /// أذكار بعد الصلاة
  static final AzkarCategory _afterPrayerAzkar = AzkarCategory(
    id: 'after_prayer',
    title: 'أذكار بعد الصلاة',
    subtitle: 'ما يقال بعد كل صلاة مفروضة',
    icon: Icons.mosque,
    color: const Color(0xFF0D5C36),
    items: [
      AzkarItem(
        id: 'prayer_1',
        text: 'أستغفر الله',
        translation: 'أَسْتَغْفِرُ اللَّهَ (3 مرات)\nاللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'prayer_2',
        text: 'لا إله إلا الله',
        translation: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        reference: 'رواه مسلم',
        fadl: 'من قالها عشر مرات بنى الله له قصراً في الجنة',
        count: 10,
      ),
      AzkarItem(
        id: 'prayer_3',
        text: 'سبحان الله',
        translation: 'سُبْحَانَ اللَّهِ',
        reference: 'رواه مسلم',
        count: 33,
      ),
      AzkarItem(
        id: 'prayer_4',
        text: 'الحمد لله',
        translation: 'الْحَمْدُ لِلَّهِ',
        reference: 'رواه مسلم',
        count: 33,
      ),
      AzkarItem(
        id: 'prayer_5',
        text: 'الله أكبر',
        translation: 'اللَّهُ أَكْبَرُ',
        reference: 'رواه مسلم',
        count: 33,
      ),
      AzkarItem(
        id: 'prayer_6',
        text: 'لا إله إلا الله وحده',
        translation: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'prayer_7',
        text: 'آية الكرسي',
        translation: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        reference: 'رواه النسائي',
        count: 1,
      ),
      AzkarItem(
        id: 'prayer_8',
        text: 'الإخلاص والمعوذتين',
        translation: 'قُلْ هُوَ اللَّهُ أَحَدٌ...\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ...\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        reference: 'رواه أبو داود',
        fadl: 'ثلاث مرات بعد صلاة الفجر والمغرب',
        count: 3,
      ),
    ],
  );

  /// أذكار النوم
  static final AzkarCategory _sleepAzkar = AzkarCategory(
    id: 'sleep',
    title: 'أذكار النوم',
    subtitle: 'ما يقال قبل النوم',
    icon: Icons.bedtime,
    color: const Color(0xFF7E57C2),
    items: [
      AzkarItem(
        id: 'sleep_1',
        text: 'باسمك اللهم أموت وأحيا',
        translation: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        reference: 'رواه البخاري',
        count: 1,
      ),
      AzkarItem(
        id: 'sleep_2',
        text: 'الحمد لله الذي أطعمنا',
        translation: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا، وَكَفَانَا وَآوَانَا، فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُؤْوِيَ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'sleep_3',
        text: 'اللهم باسمك أموت',
        translation: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
        reference: 'رواه أبو داود',
        count: 3,
      ),
      AzkarItem(
        id: 'sleep_4',
        text: 'اللهم إني أسلمت نفسي',
        translation: 'اللَّهُمَّ إِنِّي أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنْكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنْزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
        reference: 'رواه البخاري ومسلم',
        fadl: 'من قالها مات من ليلته مات على الفطرة',
        count: 1,
      ),
      AzkarItem(
        id: 'sleep_5',
        text: 'اللهم أنت ربي',
        translation: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
        reference: 'رواه البخاري',
        fadl: 'من قالها حين يصبح أو يمسي موقناً بها فمات من يومه أو ليلته دخل الجنة',
        count: 1,
      ),
      AzkarItem(
        id: 'sleep_6',
        text: 'سبحان الله',
        translation: 'سُبْحَانَ اللَّهِ (33 مرة)\nالْحَمْدُ لِلَّهِ (33 مرة)\nاللَّهُ أَكْبَرُ (34 مرة)',
        reference: 'رواه البخاري ومسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'sleep_7',
        text: 'آية الكرسي',
        translation: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        reference: 'رواه البخاري',
        fadl: 'من قالها حين يضطجع أجير من الشيطان حتى يصبح',
        count: 1,
      ),
    ],
  );

  /// أذكار الاستيقاظ
  static final AzkarCategory _wakingAzkar = AzkarCategory(
    id: 'waking',
    title: 'أذكار الاستيقاظ',
    subtitle: 'ما يقال عند الاستيقاظ من النوم',
    icon: Icons.wb_sunny,
    color: const Color(0xFFFF7043),
    items: [
      AzkarItem(
        id: 'waking_1',
        text: 'الحمد لله الذي أحيانا',
        translation: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا، وَإِلَيْهِ النُّشُورُ',
        reference: 'رواه البخاري',
        count: 1,
      ),
      AzkarItem(
        id: 'waking_2',
        text: 'الحمد لله الذي رد علي',
        translation: 'الْحَمْدُ لِلَّهِ الَّذِي رَدَّ عَلَيَّ رُوحِي، وَعَافَانِي فِي جَسَدِي، وَأَذِنَ لِي بِذِكْرِهِ',
        reference: 'رواه الترمذي',
        count: 1,
      ),
      AzkarItem(
        id: 'waking_3',
        text: 'لا إله إلا الله وحده',
        translation: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
        reference: 'رواه البخاري',
        count: 1,
      ),
    ],
  );

  /// أذكار المسجد
  static final AzkarCategory _mosqueAzkar = AzkarCategory(
    id: 'mosque',
    title: 'أذكار المسجد',
    subtitle: 'ما يقال عند دخول وخروج المسجد',
    icon: Icons.mosque,
    color: const Color(0xFF00897B),
    items: [
      AzkarItem(
        id: 'mosque_1',
        text: 'دخول المسجد',
        translation: 'يَبْدَأُ بِرِجْلِهِ الْيُمْنَىٰ، وَيَقُولُ: أَعُوذُ بِاللَّهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ\n\nبِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        reference: 'رواه أبو داود ومسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'mosque_2',
        text: 'خروج المسجد',
        translation: 'يَبْدَأُ بِرِجْلِهِ الْيُسْرَىٰ، وَيَقُولُ: بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        reference: 'رواه مسلم',
        count: 1,
      ),
    ],
  );

  /// أذكار الطعام
  static final AzkarCategory _eatingAzkar = AzkarCategory(
    id: 'eating',
    title: 'أذكار الطعام',
    subtitle: 'ما يقال قبل وبعد الأكل',
    icon: Icons.restaurant,
    color: const Color(0xFF8D6E63),
    items: [
      AzkarItem(
        id: 'eating_1',
        text: 'دعاء قبل الطعام',
        translation: 'بِسْمِ اللَّهِ',
        reference: 'رواه البخاري',
        count: 1,
      ),
      AzkarItem(
        id: 'eating_2',
        text: 'دعاء الطعام',
        translation: 'بِسْمِ اللَّهِ فِي أَوَّلِهِ، وَالْحَمْدُ لِلَّهِ فِي آخِرِهِ',
        reference: 'رواه أبو داود والترمذي',
        count: 1,
      ),
      AzkarItem(
        id: 'eating_3',
        text: 'دعاء بعد الطعام',
        translation: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ، مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'eating_4',
        text: 'دعاء الضيف',
        translation: 'اللَّهُمَّ أَطْعِمْ مَنْ أَطْعَمَنِي، وَاسْقِ مَنْ سَقَانِي',
        reference: 'رواه مسلم',
        count: 1,
      ),
    ],
  );

  /// أذكار السفر
  static final AzkarCategory _travelAzkar = AzkarCategory(
    id: 'travel',
    title: 'أذكار السفر',
    subtitle: 'ما يقال عند السفر والركوب',
    icon: Icons.flight_takeoff,
    color: const Color(0xFF039BE5),
    items: [
      AzkarItem(
        id: 'travel_1',
        text: 'دعاء السفر',
        translation: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا، وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
        reference: 'الزخرف 13-14',
        count: 1,
      ),
      AzkarItem(
        id: 'travel_2',
        text: 'تكبيرات السفر',
        translation: 'اللَّهُ أَكْبَرُ (3 مرات)\nسُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا، وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ\nاللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَىٰ، وَمِنَ الْعَمَلِ مَا تَرْضَىٰ، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الْأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ وَعْثَاءِ السَّفَرِ، وَكَآبَةِ الْمَنْظَرِ، وَسُوءِ الْمُنْقَلَبِ فِي الْمَالِ وَالْأَهْلِ',
        reference: 'رواه مسلم',
        count: 1,
      ),
      AzkarItem(
        id: 'travel_3',
        text: 'العودة من السفر',
        translation: 'آيِبُونَ، تَائِبُونَ، عَابِدُونَ، لِرَبِّنَا حَامِدُونَ',
        reference: 'رواه مسلم',
        count: 1,
      ),
    ],
  );

  /// أذكار الرقية
  static final AzkarCategory _ruqyaAzkar = AzkarCategory(
    id: 'ruqya',
    title: 'الرقية الشرعية',
    subtitle: 'الأذكار للتحصن والعلاج',
    icon: Icons.healing,
    color: const Color(0xFFE53935),
    items: [
      AzkarItem(
        id: 'ruqya_1',
        text: 'بسم الله الذي لا يضر',
        translation: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ',
        reference: 'رواه الترمذي',
        fadl: 'من قالها ثلاث مرات حين يصبح وثلاث مرات حين يمسي لم يضره شيء',
        count: 3,
      ),
      AzkarItem(
        id: 'ruqya_2',
        text: 'أعوذ بعزة الله',
        translation: 'أَعُوذُ بِعِزَّةِ اللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ',
        reference: 'رواه مسلم',
        fadl: 'الرقية للمريض',
        count: 7,
      ),
      AzkarItem(
        id: 'ruqya_3',
        text: 'أعوذ بكلمات الله',
        translation: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        reference: 'رواه مسلم',
        count: 3,
      ),
      AzkarItem(
        id: 'ruqya_4',
        text: 'الفاتحة',
        translation: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ...',
        reference: 'الرقية بالفاتحة',
        fadl: 'افتتحها بسم الله',
        count: 7,
      ),
      AzkarItem(
        id: 'ruqya_5',
        text: 'آية الكرسي',
        translation: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
        reference: 'البقرة 255',
        count: 1,
      ),
      AzkarItem(
        id: 'ruqya_6',
        text: 'المعوذتين',
        translation: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ...\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        reference: 'رواه البخاري',
        count: 3,
      ),
    ],
  );
}
