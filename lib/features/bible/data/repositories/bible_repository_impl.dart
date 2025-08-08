import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapters.dart';
import '../../domain/entities/verse.dart' hide Testament;
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_api_service.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleApiService remoteDataSource;

  BibleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BibleBook>> getBooks() async {
   return [
  BibleBook(name: "Genesis", abbreviation: "Gen", chaptersCount: 50, testament: Testament.old, order: 1),
  BibleBook(name: "Exodus", abbreviation: "Exod", chaptersCount: 40, testament: Testament.old, order: 2),
  BibleBook(name: "Leviticus", abbreviation: "Lev", chaptersCount: 27, testament: Testament.old, order: 3),
  BibleBook(name: "Numbers", abbreviation: "Num", chaptersCount: 36, testament: Testament.old, order: 4),
  BibleBook(name: "Deuteronomy", abbreviation: "Deut", chaptersCount: 34, testament: Testament.old, order: 5),
  BibleBook(name: "Joshua", abbreviation: "Josh", chaptersCount: 24, testament: Testament.old, order: 6),
  BibleBook(name: "Judges", abbreviation: "Judg", chaptersCount: 21, testament: Testament.old, order: 7),
  BibleBook(name: "Ruth", abbreviation: "Ruth", chaptersCount: 4, testament: Testament.old, order: 8),
  BibleBook(name: "1 Samuel", abbreviation: "1Sam", chaptersCount: 31, testament: Testament.old, order: 9),
  BibleBook(name: "2 Samuel", abbreviation: "2Sam", chaptersCount: 24, testament: Testament.old, order: 10),
  BibleBook(name: "1 Kings", abbreviation: "1Kgs", chaptersCount: 22, testament: Testament.old, order: 11),
  BibleBook(name: "2 Kings", abbreviation: "2Kgs", chaptersCount: 25, testament: Testament.old, order: 12),
  BibleBook(name: "1 Chronicles", abbreviation: "1Chr", chaptersCount: 29, testament: Testament.old, order: 13),
  BibleBook(name: "2 Chronicles", abbreviation: "2Chr", chaptersCount: 36, testament: Testament.old, order: 14),
  BibleBook(name: "Ezra", abbreviation: "Ezra", chaptersCount: 10, testament: Testament.old, order: 15),
  BibleBook(name: "Nehemiah", abbreviation: "Neh", chaptersCount: 13, testament: Testament.old, order: 16),
  BibleBook(name: "Esther", abbreviation: "Esth", chaptersCount: 10, testament: Testament.old, order: 17),
  BibleBook(name: "Job", abbreviation: "Job", chaptersCount: 42, testament: Testament.old, order: 18),
  BibleBook(name: "Psalms", abbreviation: "Ps", chaptersCount: 150, testament: Testament.old, order: 19),
  BibleBook(name: "Proverbs", abbreviation: "Prov", chaptersCount: 31, testament: Testament.old, order: 20),
  BibleBook(name: "Ecclesiastes", abbreviation: "Eccl", chaptersCount: 12, testament: Testament.old, order: 21),
  BibleBook(name: "Song of Solomon", abbreviation: "Song", chaptersCount: 8, testament: Testament.old, order: 22),
  BibleBook(name: "Isaiah", abbreviation: "Isa", chaptersCount: 66, testament: Testament.old, order: 23),
  BibleBook(name: "Jeremiah", abbreviation: "Jer", chaptersCount: 52, testament: Testament.old, order: 24),
  BibleBook(name: "Lamentations", abbreviation: "Lam", chaptersCount: 5, testament: Testament.old, order: 25),
  BibleBook(name: "Ezekiel", abbreviation: "Ezek", chaptersCount: 48, testament: Testament.old, order: 26),
  BibleBook(name: "Daniel", abbreviation: "Dan", chaptersCount: 12, testament: Testament.old, order: 27),
  BibleBook(name: "Hosea", abbreviation: "Hos", chaptersCount: 14, testament: Testament.old, order: 28),
  BibleBook(name: "Joel", abbreviation: "Joel", chaptersCount: 3, testament: Testament.old, order: 29),
  BibleBook(name: "Amos", abbreviation: "Amos", chaptersCount: 9, testament: Testament.old, order: 30),
  BibleBook(name: "Obadiah", abbreviation: "Obad", chaptersCount: 1, testament: Testament.old, order: 31),
  BibleBook(name: "Jonah", abbreviation: "Jonah", chaptersCount: 4, testament: Testament.old, order: 32),
  BibleBook(name: "Micah", abbreviation: "Mic", chaptersCount: 7, testament: Testament.old, order: 33),
  BibleBook(name: "Nahum", abbreviation: "Nah", chaptersCount: 3, testament: Testament.old, order: 34),
  BibleBook(name: "Habakkuk", abbreviation: "Hab", chaptersCount: 3, testament: Testament.old, order: 35),
  BibleBook(name: "Zephaniah", abbreviation: "Zeph", chaptersCount: 3, testament: Testament.old, order: 36),
  BibleBook(name: "Haggai", abbreviation: "Hag", chaptersCount: 2, testament: Testament.old, order: 37),
  BibleBook(name: "Zechariah", abbreviation: "Zech", chaptersCount: 14, testament: Testament.old, order: 38),
  BibleBook(name: "Malachi", abbreviation: "Mal", chaptersCount: 4, testament: Testament.old, order: 39),
  BibleBook(name: "Matthew", abbreviation: "Matt", chaptersCount: 28, testament: Testament.newTestament, order: 40),
  BibleBook(name: "Mark", abbreviation: "Mark", chaptersCount: 16, testament: Testament.newTestament, order: 41),
  BibleBook(name: "Luke", abbreviation: "Luke", chaptersCount: 24, testament: Testament.newTestament, order: 42),
  BibleBook(name: "John", abbreviation: "John", chaptersCount: 21, testament: Testament.newTestament, order: 43),
  BibleBook(name: "Acts", abbreviation: "Acts", chaptersCount: 28, testament: Testament.newTestament, order: 44),
  BibleBook(name: "Romans", abbreviation: "Rom", chaptersCount: 16, testament: Testament.newTestament, order: 45),
  BibleBook(name: "1 Corinthians", abbreviation: "1Cor", chaptersCount: 16, testament: Testament.newTestament, order: 46),
  BibleBook(name: "2 Corinthians", abbreviation: "2Cor", chaptersCount: 13, testament: Testament.newTestament, order: 47),
  BibleBook(name: "Galatians", abbreviation: "Gal", chaptersCount: 6, testament: Testament.newTestament, order: 48),
  BibleBook(name: "Ephesians", abbreviation: "Eph", chaptersCount: 6, testament: Testament.newTestament, order: 49),
  BibleBook(name: "Philippians", abbreviation: "Phil", chaptersCount: 4, testament: Testament.newTestament, order: 50),
  BibleBook(name: "Colossians", abbreviation: "Col", chaptersCount: 4, testament: Testament.newTestament, order: 51),
  BibleBook(name: "1 Thessalonians", abbreviation: "1Thess", chaptersCount: 5, testament: Testament.newTestament, order: 52),
  BibleBook(name: "2 Thessalonians", abbreviation: "2Thess", chaptersCount: 3, testament: Testament.newTestament, order: 53),
  BibleBook(name: "1 Timothy", abbreviation: "1Tim", chaptersCount: 6, testament: Testament.newTestament, order: 54),
  BibleBook(name: "2 Timothy", abbreviation: "2Tim", chaptersCount: 4, testament: Testament.newTestament, order: 55),
  BibleBook(name: "Titus", abbreviation: "Titus", chaptersCount: 3, testament: Testament.newTestament, order: 56),
  BibleBook(name: "Philemon", abbreviation: "Phlm", chaptersCount: 1, testament: Testament.newTestament, order: 57),
  BibleBook(name: "Hebrews", abbreviation: "Heb", chaptersCount: 13, testament: Testament.newTestament, order: 58),
  BibleBook(name: "James", abbreviation: "Jas", chaptersCount: 5, testament: Testament.newTestament, order: 59),
  BibleBook(name: "1 Peter", abbreviation: "1Pet", chaptersCount: 5, testament: Testament.newTestament, order: 60),
  BibleBook(name: "2 Peter", abbreviation: "2Pet", chaptersCount: 3, testament: Testament.newTestament, order: 61),
  BibleBook(name: "1 John", abbreviation: "1John", chaptersCount: 5, testament: Testament.newTestament, order: 62),
  BibleBook(name: "2 John", abbreviation: "2John", chaptersCount: 1, testament: Testament.newTestament, order: 63),
  BibleBook(name: "3 John", abbreviation: "3John", chaptersCount: 1, testament: Testament.newTestament, order: 64),
  BibleBook(name: "Jude", abbreviation: "Jude", chaptersCount: 1, testament: Testament.newTestament, order: 65),
  BibleBook(name: "Revelation", abbreviation: "Rev", chaptersCount: 22, testament: Testament.newTestament, order: 66),
];
  }

  @override
  Future<List<Chapter>> getChapters(String bookAbbreviation) async {
    // Chapters are usually sequential; we can generate them using book info
    final books = await getBooks();
    final book = books.firstWhere((b) => b.abbreviation == bookAbbreviation);
    return List.generate(
      book.chaptersCount,
      (index) => Chapter(bookAbbreviation: bookAbbreviation, chapterNumber: index + 1, versesCount: 0), // versesCount can be fetched later
    );
  }

@override
Future<List<Verse>> getVerses(String bookAbbreviation, int chapterNumber, {String translation = 'KJV'}) {
  return remoteDataSource.fetchVerses('$bookAbbreviation $chapterNumber', translation: translation);
}

@override
Future<List<Verse>> searchVerses(String query, {String translation = 'KJV'}) {
  return remoteDataSource.fetchVerses(query, translation: translation);
}

@override
Future<List<Verse>> getVerseByReference(String reference, String translation) {
  return remoteDataSource.fetchVerses(reference, translation: translation);
}

}
