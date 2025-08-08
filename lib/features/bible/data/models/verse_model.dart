import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  List<Map<String, dynamic>> _phraseData = [];
  
  VerseModel({
    required super.bookAbbreviation,
    required super.bookName,
    required super.chapterNumber,
    required super.reference,
    required super.verseNumber,
    required super.text,
    required super.translation,
    required super.testament,
    super.strongNumbers,
    super.isBookmarked,
    super.notes,
  });
  
  List<Map<String, dynamic>> get phraseData => _phraseData;

 static final Map<String, String> abbreviationToFullName = {
 "GEN": "Genesis",
  "EXO": "Exodus",
  "LEV": "Leviticus",
  "NUM": "Numbers",
  "DEU": "Deuteronomy",
  "JOS": "Joshua",
  "JDG": "Judges",
  "RUT": "Ruth",
  "1SA": "1 Samuel",
  "2SA": "2 Samuel",
  "1KI": "1 Kings",
  "2KI": "2 Kings",
  "1CH": "1 Chronicles",
  "2CH": "2 Chronicles",
  "EZR": "Ezra",
  "NEH": "Nehemiah",
  "EST": "Esther",
  "JOB": "Job",
  "PSA": "Psalms",
  "PRO": "Proverbs",
  "ECC": "Ecclesiastes",
  "SNG": "Song of Solomon",
  "ISA": "Isaiah",
  "JER": "Jeremiah",
  "LAM": "Lamentations",
  "EZK": "Ezekiel",
  "DAN": "Daniel",
  "HOS": "Hosea",
  "JOL": "Joel",
  "AMO": "Amos",
  "OBA": "Obadiah",
  "JON": "Jonah",
  "MIC": "Micah",
  "NAM": "Nahum",
  "HAB": "Habakkuk",
  "ZEP": "Zephaniah",
  "HAG": "Haggai",
  "ZEC": "Zechariah",
  "MAL": "Malachi",
  "MAT": "Matthew",
  "MRK": "Mark",
  "LUK": "Luke",
  "JHN": "John",
  "ACT": "Acts",
  "ROM": "Romans",
  "1CO": "1 Corinthians",
  "2CO": "2 Corinthians",
  "GAL": "Galatians",
  "EPH": "Ephesians",
  "PHP": "Philippians",
  "COL": "Colossians",
  "1TH": "1 Thessalonians",
  "2TH": "2 Thessalonians",
  "1TI": "1 Timothy",
  "2TI": "2 Timothy",
  "TIT": "Titus",
  "PHM": "Philemon",
  "HEB": "Hebrews",
  "JAS": "James",
  "1PE": "1 Peter",
  "2PE": "2 Peter",
  "1JN": "1 John",
  "2JN": "2 John",
  "3JN": "3 John",
  "JUD": "Jude",
  "REV": "Revelation",  };

  static String getBookNameFromAbbreviation(String abbreviation) {
    return abbreviationToFullName[abbreviation] ?? abbreviation;
  }

  factory VerseModel.fromJson(Map<String, dynamic> json, String translation) {
    String bookAbbr = json['book_id']?.toString() ?? json['book']?.toString() ?? '';
    String bookName = json['book_name']?.toString() ?? getBookNameFromAbbreviation(bookAbbr);
    final testament = _getTestament(bookAbbr);

    return VerseModel(
      bookAbbreviation: bookAbbr,
      bookName: bookName,
      chapterNumber: json['chapter'] is int
          ? json['chapter'] as int
          : int.tryParse(json['chapter']?.toString() ?? '') ?? 0,
      reference: json['reference']?.toString() ?? '',
      verseNumber: json['verse'] is int
          ? json['verse'] as int
          : int.tryParse(json['verse']?.toString() ?? '') ?? 0,
      text: json['text']?.toString() ?? '',
      translation: translation,
      testament: testament,
      strongNumbers: json['strong_numbers'] != null 
          ? List<String>.from(json['strong_numbers']) 
          : null,
      isBookmarked: json['is_bookmarked'] == 1,
      notes: json['notes'] != null 
          ? List<String>.from(json['notes'].split('|')) 
          : null,
    );
  }

  factory VerseModel.fromBibleSdkVerse(Map<String, dynamic> json, String translation, String book, int chapter, int verse) {
    String bookAbbr = book;
    String bookName = getBookNameFromAbbreviation(bookAbbr);
    final testament = _getTestament(bookAbbr);
    
    List<String>? strongNumbers;
    String text = '';
    List<Map<String, dynamic>> phraseData = [];
    
    if (json['phrases'] != null) {
      final phrases = json['phrases'] as List;
      
      // Filter phrases to only include verse content (not headers/metadata)
      final versePhrases = phrases.where((p) => 
        p['usfm'] != null && 
        (p['usfm'] as List).any((tag) => tag == 'v' || tag == 'w')
      ).toList();
      
      // Extract Strong's numbers and build phrase data
      strongNumbers = [];
      for (final phrase in versePhrases) {
        final phraseText = phrase['text']?.toString() ?? '';
        final strongsNum = phrase['strongs_number'];
        final strongsType = phrase['strongs_type'];
        
        phraseData.add({
          'text': phraseText,
          'hasStrongs': strongsNum != null,
          'strongsNumber': strongsNum != null ? '${strongsType ?? 'H'}$strongsNum' : null,
          'definition': phrase['definition'],
          'originalWord': phrase['hebrew_word'] ?? phrase['greek_word'],
        });
        
        if (strongsNum != null) {
          strongNumbers.add('${strongsType ?? 'H'}$strongsNum');
        }
      }
      
      if (strongNumbers.isEmpty) strongNumbers = null;
      text = phraseData.map((p) => p['text']).join('');
    }

    final verseModel = VerseModel(
      bookAbbreviation: bookAbbr,
      bookName: bookName,
      chapterNumber: chapter,
      reference: '$bookName $chapter:$verse',
      verseNumber: verse,
      text: text,
      translation: translation,
      testament: testament,
      strongNumbers: strongNumbers?.isNotEmpty == true ? strongNumbers : null,
      isBookmarked: false,
      notes: null,
    );
    
    // Store phrase data for rich text display
    verseModel._phraseData = phraseData;
    return verseModel;
  }

  factory VerseModel.fromBibleSdkSearch(Map<String, dynamic> json, String translation) {
    String bookAbbr = json['book']?.toString() ?? '';
    String bookName = getBookNameFromAbbreviation(bookAbbr);
    final testament = _getTestament(bookAbbr);
    
    int chapter = json['chapter'] is int ? json['chapter'] : int.tryParse(json['chapter']?.toString() ?? '') ?? 0;
    int verse = json['verse'] is int ? json['verse'] : int.tryParse(json['verse']?.toString() ?? '') ?? 0;

    return VerseModel(
      bookAbbreviation: bookAbbr,
      bookName: bookName,
      chapterNumber: chapter,
      reference: '$bookName $chapter:$verse',
      verseNumber: verse,
      text: json['text']?.toString() ?? '',
      translation: translation,
      testament: testament,
      strongNumbers: json['strongs'] != null ? List<String>.from(json['strongs']) : null,
      isBookmarked: false,
      notes: null,
    );
  }

  factory VerseModel.fromDatabase(Map<String, dynamic> map) {
    return VerseModel(
      bookAbbreviation: map['book_abbreviation'],
      bookName: map['book_name'],
      chapterNumber: map['chapter_number'],
      reference: '${map['book_name']} ${map['chapter_number']}:${map['verse_number']}',
      verseNumber: map['verse_number'],
      text: map['text'],
      translation: map['translation'],
      testament: Testament.values.firstWhere(
        (t) => t.name == map['testament'],
        orElse: () => Testament.newTestament,
      ),
      strongNumbers: map['strong_numbers']?.split(','),
      isBookmarked: map['is_bookmarked'] == 1,
      notes: map['notes']?.split('|'),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'book_abbreviation': bookAbbreviation,
      'book_name': bookName,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text': text,
      'translation': translation,
      'testament': testament.name,
      'strong_numbers': strongNumbers?.join(','),
      'is_bookmarked': isBookmarked ? 1 : 0,
      'notes': notes?.join('|'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'book': bookAbbreviation,
      'bookName': bookName,
      'chapter': chapterNumber,
      'verse': verseNumber,
      'text': text,
      'translation': translation,
      'testament': testament.name,
      'reference': reference,
    };
  }

  static String _getAbbreviationFromName(String bookName) {
    final nameToAbbr = abbreviationToFullName.map((k, v) => MapEntry(v, k));
    return nameToAbbr[bookName] ?? bookName.substring(0, 3).toUpperCase();
  }

  static Testament _getTestament(String bookAbbr) {
    const oldTestamentBooks = {
      'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT',
      '1SA', '2SA', '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH',
      'EST', 'JOB', 'PSA', 'PRO', 'ECC', 'SNG', 'ISA', 'JER',
      'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO', 'OBA', 'JON',
      'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'
    };
    return oldTestamentBooks.contains(bookAbbr) ? Testament.old : Testament.newTestament;
  }
}
