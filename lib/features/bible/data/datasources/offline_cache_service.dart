import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/verse_model.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/entities/chapters.dart';
import '../../domain/entities/verse.dart' as verse_entities;

class OfflineCacheService {
  static Database? _database;
  static const String _dbName = 'bible_cache.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        abbreviation TEXT NOT NULL UNIQUE,
        testament TEXT NOT NULL,
        chapter_count INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY,
        book_abbreviation TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_count INTEGER NOT NULL,
        FOREIGN KEY (book_abbreviation) REFERENCES books (abbreviation)
      )
    ''');

    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY,
        book_abbreviation TEXT NOT NULL,
        book_name TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        translation TEXT NOT NULL DEFAULT 'KJV',
        FOREIGN KEY (book_abbreviation) REFERENCES books (abbreviation)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_verses_lookup ON verses (book_abbreviation, chapter_number, verse_number, translation)
    ''');
  }

  Future<void> cacheBooks(List<BibleBook> books) async {
    final db = await database;
    final batch = db.batch();
    
    for (final book in books) {
      batch.insert('books', {
        'name': book.name,
        'abbreviation': book.abbreviation,
        'testament': book.testament.toString(),
        'chapter_count': book.chaptersCount,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit();
  }

  Future<void> cacheChapters(String bookAbbreviation, List<Chapter> chapters) async {
    final db = await database;
    final batch = db.batch();
    
    for (final chapter in chapters) {
      batch.insert('chapters', {
        'book_abbreviation': bookAbbreviation,
        'chapter_number': chapter.chapterNumber,
        'verse_count': chapter.versesCount,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit();
  }

  Future<void> cacheVerses(List<VerseModel> verses) async {
    final db = await database;
    final batch = db.batch();
    
    for (final verse in verses) {
      batch.insert('verses', {
        'book_abbreviation': verse.bookAbbreviation,
        'book_name': verse.bookName,
        'chapter_number': verse.chapterNumber,
        'verse_number': verse.verseNumber,
        'text': verse.text,
        'translation': verse.translation,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit();
  }

  Future<List<BibleBook>> getCachedBooks() async {
    final db = await database;
    final maps = await db.query('books', orderBy: 'id');
    
    return maps.map((map) => BibleBook(
      name: map['name'] as String,
      abbreviation: map['abbreviation'] as String,
      testament: Testament.values.firstWhere(
        (t) => t.toString() == map['testament'],
        orElse: () => Testament.old,
      ),
      chaptersCount: map['chapter_count'] as int,
      order: map['id'] as int,
    )).toList();
  }

  Future<List<Chapter>> getCachedChapters(String bookAbbreviation) async {
    final db = await database;
    final maps = await db.query(
      'chapters',
      where: 'book_abbreviation = ?',
      whereArgs: [bookAbbreviation],
      orderBy: 'chapter_number',
    );
    
    return maps.map((map) => Chapter(
      bookAbbreviation: map['book_abbreviation'] as String,
      chapterNumber: map['chapter_number'] as int,
      versesCount: map['verse_count'] as int,
    )).toList();
  }

  Future<List<VerseModel>> getCachedVerses(String bookAbbreviation, int chapterNumber, [String translation = 'KJV']) async {
    final db = await database;
    final maps = await db.query(
      'verses',
      where: 'book_abbreviation = ? AND chapter_number = ? AND translation = ?',
      whereArgs: [bookAbbreviation, chapterNumber, translation],
      orderBy: 'verse_number',
    );
    
    return maps.map((map) => VerseModel(
      bookAbbreviation: map['book_abbreviation'] as String,
      bookName: map['book_name'] as String,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      text: map['text'] as String,
      translation: map['translation'] as String,
      reference: '${map['book_name']} ${map['chapter_number']}:${map['verse_number']}',
      testament: _getTestament(map['book_abbreviation'] as String),
    )).toList();
  }

  Future<List<VerseModel>> searchCachedVerses(String query, [String translation = 'KJV']) async {
    final db = await database;
    
    // Handle phrase search by splitting into words
    final words = query.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    
    List<Map<String, Object?>> maps;
    
    if (words.length > 1) {
      // Multi-word search - find verses containing all words
      final whereConditions = words.map((_) => 'LOWER(text) LIKE ?').join(' AND ');
      final whereArgs = words.map((word) => '%$word%').toList()..add(translation);
      
      maps = await db.query(
        'verses',
        where: '($whereConditions) AND translation = ?',
        whereArgs: whereArgs,
        orderBy: 'book_abbreviation, chapter_number, verse_number',
        limit: 100,
      );
    } else {
      // Single word or phrase search
      maps = await db.query(
        'verses',
        where: 'LOWER(text) LIKE ? AND translation = ?',
        whereArgs: ['%${query.toLowerCase()}%', translation],
        orderBy: 'book_abbreviation, chapter_number, verse_number',
        limit: 100,
      );
    }
    
    return maps.map((map) => VerseModel(
      bookAbbreviation: map['book_abbreviation'] as String,
      bookName: map['book_name'] as String,
      chapterNumber: map['chapter_number'] as int,
      verseNumber: map['verse_number'] as int,
      text: map['text'] as String,
      translation: map['translation'] as String,
      reference: '${map['book_name']} ${map['chapter_number']}:${map['verse_number']}',
      testament: _getTestament(map['book_abbreviation'] as String),
    )).toList();
  }

  Future<bool> isCacheEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM books');
    return (result.first['count'] as int) == 0;
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('verses');
    await db.delete('chapters');
    await db.delete('books');
  }

  verse_entities.Testament _getTestament(String bookAbbr) {
    const oldTestamentBooks = {
      'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT',
      '1SA', '2SA', '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH',
      'EST', 'JOB', 'PSA', 'PRO', 'ECC', 'SNG', 'ISA', 'JER',
      'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO', 'OBA', 'JON',
      'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'
    };
    return oldTestamentBooks.contains(bookAbbr) ? verse_entities.Testament.old : verse_entities.Testament.newTestament;
  }
}