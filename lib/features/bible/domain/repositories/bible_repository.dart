import '../entities/bible_book.dart';
import '../entities/chapters.dart';
import '../entities/verse.dart';

abstract class BibleRepository {
  Future<List<BibleBook>> getBooks();
  Future<List<Chapter>> getChapters(String bookAbbreviation);
  Future<List<Verse>> getVerses(String bookAbbreviation, int chapterNumber, {String translation = 'KJV'});
  Future<List<Verse>> searchVerses(String query, {String translation = 'KJV', int? limit});
  Future<List<Verse>> getVerseByReference(String reference, String translation);
}
