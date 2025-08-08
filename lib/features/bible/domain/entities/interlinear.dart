class InterlinearWord {
  final String originalWord;
  final String transliteration;
  final String englishTranslation;
  final String strongNumber;
  final String morphology;
  final int position;

  InterlinearWord({
    required this.originalWord,
    required this.transliteration,
    required this.englishTranslation,
    required this.strongNumber,
    required this.morphology,
    required this.position,
  });
}

class InterlinearVerse {
  final String reference;
  final List<InterlinearWord> words;
  final String language; // 'hebrew' or 'greek'

  InterlinearVerse({
    required this.reference,
    required this.words,
    required this.language,
  });
}