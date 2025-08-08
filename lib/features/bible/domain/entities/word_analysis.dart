class WordAnalysis {
  final String word;
  final String strongsNumber;
  final int position;
  final String transliteration;
  final String definition;

  WordAnalysis({
    required this.word,
    required this.strongsNumber,
    required this.position,
    required this.transliteration,
    required this.definition,
  });
}

class StrongsEntry {
  final String number;
  final String word;
  final String transliteration;
  final String pronunciation;
  final String definition;
  final String language; // Hebrew or Greek

  StrongsEntry({
    required this.number,
    required this.word,
    required this.transliteration,
    required this.pronunciation,
    required this.definition,
    required this.language,
  });
}