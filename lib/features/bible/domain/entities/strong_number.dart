class StrongNumber {
  final String number;
  final String originalWord;
  final String transliteration;
  final String pronunciation;
  final String definition;
  final String language; // 'hebrew' or 'greek'
  final List<String> usages;

  StrongNumber({
    required this.number,
    required this.originalWord,
    required this.transliteration,
    required this.pronunciation,
    required this.definition,
    required this.language,
    required this.usages,
  });
}