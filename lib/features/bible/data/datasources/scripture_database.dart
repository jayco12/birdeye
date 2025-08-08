import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scripture_data_model.dart';

class ScriptureDatabase {
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scripture_data.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scripture_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        insights TEXT NOT NULL,
        study_questions TEXT NOT NULL,
        word_analysis TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        UNIQUE(book, chapter, verse)
      )
    ''');
    
    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_book_chapter ON scripture_data(book, chapter)');
    await db.execute('CREATE INDEX idx_reference ON scripture_data(book, chapter, verse)');
  }

  Future<void> importFromJson(String jsonFilePath) async {
    final db = await database;
    final file = File(jsonFilePath);
    
    if (!await file.exists()) {
      throw Exception('JSON file not found: $jsonFilePath');
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonString);
    
    final batch = db.batch();
    
    for (final item in data) {
      batch.insert(
        'scripture_data',
        {
          'book': item['book'],
          'chapter': item['chapter'],
          'verse': item['verse'],
          'text': item['text'],
          'insights': item['insights'],
          'study_questions': jsonEncode(item['study_questions']),
          'word_analysis': jsonEncode(item['word_analysis']),
          'generated_at': item['generated_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
    print('Imported ${data.length} scripture entries');
  }

  Future<ScriptureDataModel?> getScriptureData(String book, int chapter, int verse) async {
    final db = await database;
    final results = await db.query(
      'scripture_data',
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [book, chapter, verse],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    
    final row = results.first;
    return ScriptureDataModel(
      book: row['book'] as String,
      chapter: row['chapter'] as int,
      verse: row['verse'] as int,
      text: row['text'] as String,
      insights: row['insights'] as String,
      studyQuestions: (jsonDecode(row['study_questions'] as String) as List).cast<String>(),
      wordAnalysis: (jsonDecode(row['word_analysis'] as String) as List).map((w) => WordAnalysis.fromJson(w)).toList(),
      generatedAt: DateTime.parse(row['generated_at'] as String),
    );
  }

  Future<List<ScriptureDataModel>> getChapterData(String book, int chapter) async {
    final db = await database;
    final results = await db.query(
      'scripture_data',
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
      orderBy: 'verse ASC',
    );
    
    return results.map((row) => ScriptureDataModel(
      book: row['book'] as String,
      chapter: row['chapter'] as int,
      verse: row['verse'] as int,
      text: row['text'] as String,
      insights: row['insights'] as String,
      studyQuestions: (jsonDecode(row['study_questions'] as String) as List).cast<String>(),
      wordAnalysis: (jsonDecode(row['word_analysis'] as String) as List).map((w) => WordAnalysis.fromJson(w)).toList(),
      generatedAt: DateTime.parse(row['generated_at'] as String),
    )).toList();
  }

  Future<bool> hasData() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM scripture_data');
    return (result.first['count'] as int) > 0;
  }
}