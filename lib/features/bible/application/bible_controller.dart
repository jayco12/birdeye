
import 'package:get/get.dart';
import '../domain/entities/bible_book.dart';
import '../domain/entities/chapters.dart';
import '../domain/entities/verse.dart';
import '../domain/repositories/bible_repository.dart';
import '../data/datasources/local_storage.dart';
import '../data/models/verse_model.dart';

class BibleController extends GetxController {
  final BibleRepository repository;

  BibleController({required this.repository, });

  var books = <BibleBook>[].obs;
  var selectedBook = Rxn<BibleBook>();
  var chapters = <Chapter>[].obs;
  var selectedChapter = Rxn<Chapter>();
  var verses = <Verse>[].obs;
  var selectedTranslation = 'KJV'.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  
  // Bible comparison features
  var selectedTranslationsForComparison = <String>['KJV', 'NIV'].obs;
  var comparisonVerses = <Verse>[].obs;
  
  // Bookmarks and notes
  var bookmarkedVerses = <Verse>[].obs;
  final LocalStorage _localStorage = LocalStorage();

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await _localStorage.getBookmarks();
    bookmarkedVerses.assignAll(bookmarks);
  }

void setTranslation(String newTranslation) {
  selectedTranslation.value = newTranslation;
  // Optionally reload verses using new translation
  if (selectedBook.value != null && selectedChapter.value != null) {
    loadVerses(selectedBook.value!.abbreviation, selectedChapter.value!.chapterNumber);
  }
}

  Future<void> loadBooks() async {
    try {
      isLoading.value = true;
      error.value = '';
      final loadedBooks = await repository.getBooks();
      books.value = loadedBooks;
      if (loadedBooks.isNotEmpty) {
        selectBook(loadedBooks.first);
      }
    } catch (e) {
      error.value = 'Failed to load books';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectBook(BibleBook book) async {
    selectedBook.value = book;
    await loadChapters(book.abbreviation);
  }

  Future<void> loadChapters(String bookAbbreviation) async {
    try {
      isLoading.value = true;
      error.value = '';
      final loadedChapters = await repository.getChapters(bookAbbreviation);
      chapters.value = loadedChapters;
      if (loadedChapters.isNotEmpty) {
        selectChapter(loadedChapters.first);
      }
    } catch (e) {
      error.value = 'Failed to load chapters';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectChapter(Chapter chapter) async {
    selectedChapter.value = chapter;
    await loadVerses(chapter.bookAbbreviation, chapter.chapterNumber);
  }

Future<void> loadVersesByReference(String reference) async {
  try {
    isLoading.value = true;
    error.value = '';

    // Example input: "1 John 3:16"
    final regex = RegExp(r'^(.+?)\s+(\d+):(\d+)$');
    final match = regex.firstMatch(reference.trim());
    if (match == null) {
      error.value = 'Invalid format. Use e.g. John 3:16';
      return;
    }
    final bookName = match.group(1)!.trim();
    final chapterNum = int.tryParse(match.group(2)!);
    final verseNum = int.tryParse(match.group(3)!);

    if (chapterNum == null || verseNum == null) {
      error.value = 'Invalid chapter or verse number.';
      return;
    }

    // Try to find the book by name or abbreviation
    final book = books.firstWhereOrNull((b) =>
      b.name.toLowerCase() == bookName.toLowerCase() ||
      b.abbreviation.toLowerCase() == bookName.toLowerCase()
    );

    if (book == null) {
      error.value = 'Book not found: $bookName';
      return;
    }

    final versesResult = await repository.getVerses(book.abbreviation, chapterNum);

    final filtered = versesResult.where((v) => v.verseNumber == verseNum).toList();
    if (filtered.isEmpty) {
      error.value = 'Verse not found.';
    } else {
      verses.assignAll(filtered);

    }
  } catch (e) {
    error.value =  e.toString();
  } finally {
    isLoading.value = false;
  }
}
Future<void> searchVerses(String input) async {
  try {
    isLoading.value = true;
    error.value = '';
    verses.clear();

    final trimmedInput = input.trim();
    if (trimmedInput.isEmpty) {
      error.value = 'Please enter a search term';
      return;
    }

    // Show immediate feedback
    await Future.delayed(const Duration(milliseconds: 100));

    // Regex to detect book chapter:verse pattern (e.g. John 3:16)
    final verseRefRegex = RegExp(r'^(.+?)\s+(\d+):(\d+)$');
    final chapterRefRegex = RegExp(r'^(.+?)\s+(\d+)$');
    
    if (verseRefRegex.hasMatch(trimmedInput)) {
      // Specific verse reference (e.g., "John 3:16")
      await loadVersesByReference(trimmedInput);
    } else if (chapterRefRegex.hasMatch(trimmedInput)) {
      // Chapter reference (e.g., "John 3")
      final match = chapterRefRegex.firstMatch(trimmedInput)!;
      final bookName = match.group(1)!.trim();
      final chapterNum = int.tryParse(match.group(2)!);
      
      if (chapterNum != null) {
        final book = books.firstWhereOrNull((b) =>
          b.name.toLowerCase().contains(bookName.toLowerCase()) ||
          b.abbreviation.toLowerCase() == bookName.toLowerCase()
        );
        
        if (book != null) {
          await loadVerses(book.abbreviation, chapterNum);
        } else {
          error.value = 'Book not found: $bookName';
        }
      }
    } else {
      // Keyword/phrase search with optimization
      final results = await _performOptimizedSearch(trimmedInput);
      if (results.isEmpty) {
        error.value = 'No verses found for "$trimmedInput"';
      } else {
        verses.assignAll(results);
      }
    }
  } catch (e) {
    error.value = 'Search failed: ${e.toString()}';
  } finally {
    isLoading.value = false;
  }
}

Future<List<Verse>> _performOptimizedSearch(String query) async {
  // Use a timeout to prevent long searches
  return await repository.searchVerses(
    query, 
    translation: selectedTranslation.value,
    limit: 50, // Limit results for faster loading
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      throw Exception('Search timeout - please try a more specific query');
    },
  );
}


  Future<void> loadVerses(String bookAbbreviation, int chapterNumber) async {
    try {
      isLoading.value = true;
      error.value = '';
      final loadedVerses = await repository.getVerses(bookAbbreviation, chapterNumber);
      verses.assignAll(loadedVerses);

    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Bible comparison methods
  void addTranslationToComparison(String translation) {
    if (!selectedTranslationsForComparison.contains(translation)) {
      selectedTranslationsForComparison.add(translation);
    }
  }

  void removeTranslationFromComparison(String translation) {
    selectedTranslationsForComparison.remove(translation);
  }

  Future<void> loadVerseForComparison(String reference) async {
    try {
      comparisonVerses.clear();
      for (String translation in selectedTranslationsForComparison) {
        // Load verse for each translation
        final verses = await repository.getVerseByReference(reference, translation);
        if (verses.isNotEmpty) {
          comparisonVerses.add(verses.first);
        }
      }
    } catch (e) {
      error.value = 'Failed to load comparison: ${e.toString()}';
    }
  }

  // Bookmark methods
  void toggleBookmark(Verse verse) async {
    if (isBookmarked(verse)) {
      bookmarkedVerses.removeWhere((v) => _isSameVerse(v, verse));
    } else {
      bookmarkedVerses.add(verse);
    }
    await _localStorage.saveBookmarks(bookmarkedVerses.cast<VerseModel>());
  }

  bool isBookmarked(Verse verse) {
    return bookmarkedVerses.any((v) => _isSameVerse(v, verse));
  }

  bool _isSameVerse(Verse v1, Verse v2) {
    return v1.bookAbbreviation == v2.bookAbbreviation &&
           v1.chapterNumber == v2.chapterNumber &&
           v1.verseNumber == v2.verseNumber &&
           v1.translation == v2.translation;
  }
}
