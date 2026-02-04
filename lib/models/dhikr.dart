class Dhikr {
  final String arabicText;
  final String englishText;
  final String translation;
  final int target;

  const Dhikr({
    required this.arabicText,
    required this.englishText,
    required this.translation,
    required this.target,
  });

  static const List<Dhikr> presets = [
    Dhikr(
      arabicText: 'سُبْحَانَ اللَّهِ',
      englishText: 'Subhanallah',
      translation: 'Glory be to Allah',
      target: 33,
    ),
    Dhikr(
      arabicText: 'الْحَمْدُ لِلَّهِ',
      englishText: 'Alhamdulillah',
      translation: 'All praise is due to Allah',
      target: 33,
    ),
    Dhikr(
      arabicText: 'اللَّهُ أَكْبَرُ',
      englishText: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      target: 34,
    ),
    Dhikr(
      arabicText: 'أَسْتَغْفِرُ اللَّهَ',
      englishText: 'Astaghfirullah',
      translation: 'I seek forgiveness from Allah',
      target: 100,
    ),
  ];
}
