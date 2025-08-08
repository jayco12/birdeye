import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/verse_model.dart';

class LocalDatabase {
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bible.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE verses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_abbreviation TEXT,
        book_name TEXT,
        chapter_number INTEGER,
        verse_number INTEGER,
        text TEXT,
        translation TEXT,
        testament TEXT,
        strong_numbers TEXT,
        is_bookmarked INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE strong_numbers(
        number TEXT PRIMARY KEY,
        original_word TEXT,
        transliteration TEXT,
        pronunciation TEXT,
        definition TEXT,
        language TEXT,
        usages TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE commentaries(
        id TEXT PRIMARY KEY,
        author TEXT,
        title TEXT,
        content TEXT,
        reference TEXT,
        type TEXT
      )
    ''');
  }

  Future<List<VerseModel>> getVerses(String book, int chapter, String translation) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'book_abbreviation = ? AND chapter_number = ? AND translation = ?',
      whereArgs: [book, chapter, translation],
    );
    return List.generate(maps.length, (i) => VerseModel.fromDatabase(maps[i]));
  }

  Future<void> insertVerse(VerseModel verse) async {
    final db = await database;
    await db.insert('verses', verse.toDatabase(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> toggleBookmark(String reference) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE verses SET is_bookmarked = CASE WHEN is_bookmarked = 1 THEN 0 ELSE 1 END WHERE reference = ?',
      [reference],
    );
  }
}