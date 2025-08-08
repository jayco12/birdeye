import 'package:get/get.dart';
import 'bible_api_service.dart';
import 'offline_cache_service.dart';
import '../models/verse_model.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapters.dart';
import 'package:http/http.dart' as http;

class BibleDataPreloader {
  final BibleApiService _apiService = BibleApiService(http.Client());
  final OfflineCacheService _cacheService = OfflineCacheService();
  
  final RxDouble progress = 0.0.obs;
  final RxString currentTask = ''.obs;
  final RxBool isPreloading = false.obs;

  Future<void> preloadAllBibleData() async {
    if (isPreloading.value) return;
    
    try {
      isPreloading.value = true;
      progress.value = 0.0;
      
      // Check if cache already exists
      if (!await _cacheService.isCacheEmpty()) {
        currentTask.value = 'Bible data already cached';
        progress.value = 1.0;
        return;
      }

      currentTask.value = 'Loading books...';
      final books = _getHardcodedBooks();
      await _cacheService.cacheBooks(books);
      progress.value = 0.1;

      int totalChapters = 0;
      int processedChapters = 0;

      // First pass: cache chapters and count total
      for (final book in books) {
        currentTask.value = 'Loading chapters for ${book.name}...';
        final chapters = _generateChapters(book);
        await _cacheService.cacheChapters(book.abbreviation, chapters);
        totalChapters += chapters.length;
      }
      progress.value = 0.2;

      // Second pass: cache all verses
      for (final book in books) {
        final chapters = await _cacheService.getCachedChapters(book.abbreviation);
        
        for (final chapter in chapters) {
          currentTask.value = 'Loading ${book.name} ${chapter.chapterNumber}...';
          
          try {
            final verses = await _apiService.fetchVerses('${book.abbreviation} ${chapter.chapterNumber}');
            await _cacheService.cacheVerses(verses.cast<VerseModel>());
            
            processedChapters++;
            progress.value = 0.2 + (0.8 * processedChapters / totalChapters);
            
            // Small delay to prevent overwhelming the API
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            print('Error loading ${book.abbreviation} ${chapter.chapterNumber}: $e');
            // Continue with next chapter
          }
        }
      }

      currentTask.value = 'Bible data cached successfully!';
      progress.value = 1.0;
      
    } catch (e) {
      currentTask.value = 'Error: $e';
      throw Exception('Failed to preload Bible data: $e');
    } finally {
      isPreloading.value = false;
    }
  }

  Future<void> preloadEssentialBooks() async {
    // Preload only essential books for faster startup
    final essentialBooks = [
      'GEN', 'EXO', 'PSA', 'PRO', 'ISA', 'JER', 'EZE', 'DAN',
      'MAT', 'MAR', 'LUK', 'JOH', 'ACT', 'ROM', '1CO', '2CO',
      'GAL', 'EPH', 'PHI', 'COL', '1TH', '2TH', '1TI', '2TI',
      'TIT', 'PHM', 'HEB', 'JAM', '1PE', '2PE', '1JO', '2JO',
      '3JO', 'JUD', 'REV'
    ];

    try {
      isPreloading.value = true;
      progress.value = 0.0;
      currentTask.value = 'Loading essential books...';

      final allBooks = _getHardcodedBooks();
      final books = allBooks.where((b) => essentialBooks.contains(b.abbreviation)).toList();
      
      await _cacheService.cacheBooks(allBooks); // Cache all books metadata
      
      int totalChapters = 0;
      int processedChapters = 0;

      // Count chapters
      for (final book in books) {
        final chapters = _generateChapters(book);
        await _cacheService.cacheChapters(book.abbreviation, chapters);
        totalChapters += chapters.length;
      }

      // Cache verses
      for (final book in books) {
        final chapters = await _cacheService.getCachedChapters(book.abbreviation);
        
        for (final chapter in chapters) {
          currentTask.value = 'Loading ${book.name} ${chapter.chapterNumber}...';
          
          try {
            final verses = await _apiService.fetchVerses('${book.abbreviation} ${chapter.chapterNumber}');
            await _cacheService.cacheVerses(verses.cast<VerseModel>());
            
            processedChapters++;
            progress.value = processedChapters / totalChapters;
          } catch (e) {
            print('Error loading ${book.abbreviation} ${chapter.chapterNumber}: $e');
          }
        }
      }

      currentTask.value = 'Essential books cached!';
      progress.value = 1.0;
      
    } catch (e) {
      currentTask.value = 'Error: $e';
      throw Exception('Failed to preload essential books: $e');
    } finally {
      isPreloading.value = false;
    }
  }

  List<BibleBook> _getHardcodedBooks() {
    return [
      BibleBook(name: "Genesis", abbreviation: "GEN", chaptersCount: 50, testament: Testament.old, order: 1),
      BibleBook(name: "Exodus", abbreviation: "EXO", chaptersCount: 40, testament: Testament.old, order: 2),
      BibleBook(name: "Leviticus", abbreviation: "LEV", chaptersCount: 27, testament: Testament.old, order: 3),
      BibleBook(name: "Numbers", abbreviation: "NUM", chaptersCount: 36, testament: Testament.old, order: 4),
      BibleBook(name: "Deuteronomy", abbreviation: "DEU", chaptersCount: 34, testament: Testament.old, order: 5),
      BibleBook(name: "Joshua", abbreviation: "JOS", chaptersCount: 24, testament: Testament.old, order: 6),
      BibleBook(name: "Judges", abbreviation: "JDG", chaptersCount: 21, testament: Testament.old, order: 7),
      BibleBook(name: "Ruth", abbreviation: "RUT", chaptersCount: 4, testament: Testament.old, order: 8),
      BibleBook(name: "1 Samuel", abbreviation: "1SA", chaptersCount: 31, testament: Testament.old, order: 9),
      BibleBook(name: "2 Samuel", abbreviation: "2SA", chaptersCount: 24, testament: Testament.old, order: 10),
      BibleBook(name: "1 Kings", abbreviation: "1KI", chaptersCount: 22, testament: Testament.old, order: 11),
      BibleBook(name: "2 Kings", abbreviation: "2KI", chaptersCount: 25, testament: Testament.old, order: 12),
      BibleBook(name: "1 Chronicles", abbreviation: "1CH", chaptersCount: 29, testament: Testament.old, order: 13),
      BibleBook(name: "2 Chronicles", abbreviation: "2CH", chaptersCount: 36, testament: Testament.old, order: 14),
      BibleBook(name: "Ezra", abbreviation: "EZR", chaptersCount: 10, testament: Testament.old, order: 15),
      BibleBook(name: "Nehemiah", abbreviation: "NEH", chaptersCount: 13, testament: Testament.old, order: 16),
      BibleBook(name: "Esther", abbreviation: "EST", chaptersCount: 10, testament: Testament.old, order: 17),
      BibleBook(name: "Job", abbreviation: "JOB", chaptersCount: 42, testament: Testament.old, order: 18),
      BibleBook(name: "Psalms", abbreviation: "PSA", chaptersCount: 150, testament: Testament.old, order: 19),
      BibleBook(name: "Proverbs", abbreviation: "PRO", chaptersCount: 31, testament: Testament.old, order: 20),
      BibleBook(name: "Ecclesiastes", abbreviation: "ECC", chaptersCount: 12, testament: Testament.old, order: 21),
      BibleBook(name: "Song of Solomon", abbreviation: "SNG", chaptersCount: 8, testament: Testament.old, order: 22),
      BibleBook(name: "Isaiah", abbreviation: "ISA", chaptersCount: 66, testament: Testament.old, order: 23),
      BibleBook(name: "Jeremiah", abbreviation: "JER", chaptersCount: 52, testament: Testament.old, order: 24),
      BibleBook(name: "Lamentations", abbreviation: "LAM", chaptersCount: 5, testament: Testament.old, order: 25),
      BibleBook(name: "Ezekiel", abbreviation: "EZK", chaptersCount: 48, testament: Testament.old, order: 26),
      BibleBook(name: "Daniel", abbreviation: "DAN", chaptersCount: 12, testament: Testament.old, order: 27),
      BibleBook(name: "Hosea", abbreviation: "HOS", chaptersCount: 14, testament: Testament.old, order: 28),
      BibleBook(name: "Joel", abbreviation: "JOL", chaptersCount: 3, testament: Testament.old, order: 29),
      BibleBook(name: "Amos", abbreviation: "AMO", chaptersCount: 9, testament: Testament.old, order: 30),
      BibleBook(name: "Obadiah", abbreviation: "OBA", chaptersCount: 1, testament: Testament.old, order: 31),
      BibleBook(name: "Jonah", abbreviation: "JON", chaptersCount: 4, testament: Testament.old, order: 32),
      BibleBook(name: "Micah", abbreviation: "MIC", chaptersCount: 7, testament: Testament.old, order: 33),
      BibleBook(name: "Nahum", abbreviation: "NAM", chaptersCount: 3, testament: Testament.old, order: 34),
      BibleBook(name: "Habakkuk", abbreviation: "HAB", chaptersCount: 3, testament: Testament.old, order: 35),
      BibleBook(name: "Zephaniah", abbreviation: "ZEP", chaptersCount: 3, testament: Testament.old, order: 36),
      BibleBook(name: "Haggai", abbreviation: "HAG", chaptersCount: 2, testament: Testament.old, order: 37),
      BibleBook(name: "Zechariah", abbreviation: "ZEC", chaptersCount: 14, testament: Testament.old, order: 38),
      BibleBook(name: "Malachi", abbreviation: "MAL", chaptersCount: 4, testament: Testament.old, order: 39),
      BibleBook(name: "Matthew", abbreviation: "MAT", chaptersCount: 28, testament: Testament.newTestament, order: 40),
      BibleBook(name: "Mark", abbreviation: "MRK", chaptersCount: 16, testament: Testament.newTestament, order: 41),
      BibleBook(name: "Luke", abbreviation: "LUK", chaptersCount: 24, testament: Testament.newTestament, order: 42),
      BibleBook(name: "John", abbreviation: "JHN", chaptersCount: 21, testament: Testament.newTestament, order: 43),
      BibleBook(name: "Acts", abbreviation: "ACT", chaptersCount: 28, testament: Testament.newTestament, order: 44),
      BibleBook(name: "Romans", abbreviation: "ROM", chaptersCount: 16, testament: Testament.newTestament, order: 45),
      BibleBook(name: "1 Corinthians", abbreviation: "1CO", chaptersCount: 16, testament: Testament.newTestament, order: 46),
      BibleBook(name: "2 Corinthians", abbreviation: "2CO", chaptersCount: 13, testament: Testament.newTestament, order: 47),
      BibleBook(name: "Galatians", abbreviation: "GAL", chaptersCount: 6, testament: Testament.newTestament, order: 48),
      BibleBook(name: "Ephesians", abbreviation: "EPH", chaptersCount: 6, testament: Testament.newTestament, order: 49),
      BibleBook(name: "Philippians", abbreviation: "PHP", chaptersCount: 4, testament: Testament.newTestament, order: 50),
      BibleBook(name: "Colossians", abbreviation: "COL", chaptersCount: 4, testament: Testament.newTestament, order: 51),
      BibleBook(name: "1 Thessalonians", abbreviation: "1TH", chaptersCount: 5, testament: Testament.newTestament, order: 52),
      BibleBook(name: "2 Thessalonians", abbreviation: "2TH", chaptersCount: 3, testament: Testament.newTestament, order: 53),
      BibleBook(name: "1 Timothy", abbreviation: "1TI", chaptersCount: 6, testament: Testament.newTestament, order: 54),
      BibleBook(name: "2 Timothy", abbreviation: "2TI", chaptersCount: 4, testament: Testament.newTestament, order: 55),
      BibleBook(name: "Titus", abbreviation: "TIT", chaptersCount: 3, testament: Testament.newTestament, order: 56),
      BibleBook(name: "Philemon", abbreviation: "PHM", chaptersCount: 1, testament: Testament.newTestament, order: 57),
      BibleBook(name: "Hebrews", abbreviation: "HEB", chaptersCount: 13, testament: Testament.newTestament, order: 58),
      BibleBook(name: "James", abbreviation: "JAS", chaptersCount: 5, testament: Testament.newTestament, order: 59),
      BibleBook(name: "1 Peter", abbreviation: "1PE", chaptersCount: 5, testament: Testament.newTestament, order: 60),
      BibleBook(name: "2 Peter", abbreviation: "2PE", chaptersCount: 3, testament: Testament.newTestament, order: 61),
      BibleBook(name: "1 John", abbreviation: "1JN", chaptersCount: 5, testament: Testament.newTestament, order: 62),
      BibleBook(name: "2 John", abbreviation: "2JN", chaptersCount: 1, testament: Testament.newTestament, order: 63),
      BibleBook(name: "3 John", abbreviation: "3JN", chaptersCount: 1, testament: Testament.newTestament, order: 64),
      BibleBook(name: "Jude", abbreviation: "JUD", chaptersCount: 1, testament: Testament.newTestament, order: 65),
      BibleBook(name: "Revelation", abbreviation: "REV", chaptersCount: 22, testament: Testament.newTestament, order: 66),
    ];
  }

  List<Chapter> _generateChapters(BibleBook book) {
    return List.generate(
      book.chaptersCount,
      (index) => Chapter(
        bookAbbreviation: book.abbreviation,
        chapterNumber: index + 1,
        versesCount: 0,
      ),
    );
  }
}