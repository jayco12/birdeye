import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapters.dart';
import '../../domain/entities/verse.dart' hide Testament;
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_api_service.dart';
import '../datasources/offline_cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleApiService remoteDataSource;
  final OfflineCacheService cacheService = OfflineCacheService();

  BibleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BibleBook>> getBooks() async {
    try {
      // Try cache first
      final cachedBooks = await cacheService.getCachedBooks();
      if (cachedBooks.isNotEmpty) {
        return cachedBooks;
      }
      
      // Fallback to hardcoded list
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
    } catch (e) {
      throw Exception('Failed to get books: $e');
    }
  }

  @override
  Future<List<Chapter>> getChapters(String bookAbbreviation) async {
    try {
      // Try cache first
      final cachedChapters = await cacheService.getCachedChapters(bookAbbreviation);
      if (cachedChapters.isNotEmpty) {
        return cachedChapters;
      }
      
      // Fallback to generating from book info
      final books = await getBooks();
      final book = books.firstWhere((b) => b.abbreviation == bookAbbreviation);
      return List.generate(
        book.chaptersCount,
        (index) => Chapter(bookAbbreviation: bookAbbreviation, chapterNumber: index + 1, versesCount: 0),
      );
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }

  @override
  Future<List<Verse>> getVerses(String bookAbbreviation, int chapterNumber, {String translation = 'KJV'}) async {
    try {
      // Try cache first
      final cachedVerses = await cacheService.getCachedVerses(bookAbbreviation, chapterNumber, translation);
      if (cachedVerses.isNotEmpty) {
        return cachedVerses;
      }
      
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw Exception('No internet connection and no cached data available');
      }
      
      // Fetch from API and cache
      final verses = await remoteDataSource.fetchVerses('$bookAbbreviation $chapterNumber', translation: translation);
      await cacheService.cacheVerses(verses.cast());
      return verses;
    } catch (e) {
      throw Exception('Failed to get verses: $e');
    }
  }

  @override
  Future<List<Verse>> searchVerses(String query, {String translation = 'KJV', int? limit}) async {
    try {
      final results = <Verse>[];
      
      // Try cache first for faster results
      final cachedResults = await cacheService.searchCachedVerses(query, translation);
      if (cachedResults.isNotEmpty) {
        results.addAll(cachedResults);
        // Apply limit to cached results if specified
        if (limit != null && results.length > limit) {
          return results.take(limit).toList();
        }
      }
      
      // Check connectivity for API search
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity != ConnectivityResult.none && results.length < (limit ?? 50)) {
        try {
          // Fetch from API with remaining limit
          final apiResults = await remoteDataSource.fetchVerses(
            query, 
            translation: translation,
          );
          
          // Merge results, avoiding duplicates
          for (final apiVerse in apiResults) {
            final isDuplicate = results.any((cachedVerse) => 
              cachedVerse.bookAbbreviation == apiVerse.bookAbbreviation &&
              cachedVerse.chapterNumber == apiVerse.chapterNumber &&
              cachedVerse.verseNumber == apiVerse.verseNumber
            );
            if (!isDuplicate) {
              results.add(apiVerse);
              // Break if we've reached the limit
              if (limit != null && results.length >= limit) break;
            }
          }
        } catch (apiError) {
          print('API search failed: $apiError');
          // Continue with cached results if API fails
        }
      }
      
      if (results.isEmpty) {
        throw Exception('No verses found for "$query"');
      }
      
      // Apply final limit if specified
      return limit != null ? results.take(limit).toList() : results;
    } catch (e) {
      throw Exception('Failed to search verses: $e');
    }
  }

  @override
  Future<List<Verse>> getVerseByReference(String reference, String translation) async {
    try {
      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }
      
      return await remoteDataSource.fetchVerses(reference, translation: translation);
    } catch (e) {
      throw Exception('Failed to get verse by reference: $e');
    }
  }

}
