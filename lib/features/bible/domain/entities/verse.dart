class Verse {
  final String bookAbbreviation;
  final String bookName;
  final int chapterNumber;
  final String reference;
  final int verseNumber;
  final String text;
  final String translation;
  final Testament testament;
  final List<String>? strongNumbers;
  final bool isBookmarked;
  final List<String>? notes;

  Verse({
    required this.bookAbbreviation,
    required this.bookName,
    required this.chapterNumber,
    required this.reference,
    required this.verseNumber,
    required this.text,
    required this.translation,
    required this.testament,
    this.strongNumbers,
    this.isBookmarked = false,
    this.notes,
  });
}

enum Testament { old, newTestament }
