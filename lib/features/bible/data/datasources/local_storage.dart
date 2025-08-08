import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/verse_model.dart';
import '../../domain/entities/highlight.dart';

class LocalStorage {
  static const String _bookmarksKey = 'bookmarks';
  static const String _notesKey = 'notes';
  static const String _highlightsKey = 'highlights';

  Future<List<VerseModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    return bookmarksJson.map((json) => VerseModel.fromJson(jsonDecode(json), '')).toList();
  }

  Future<void> saveBookmarks(List<VerseModel> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = bookmarks.map((verse) => jsonEncode(verse.toJson())).toList();
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  Future<Map<String, List<VerseNote>>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey) ?? '{}';
    final Map<String, dynamic> notesMap = jsonDecode(notesJson);
    
    Map<String, List<VerseNote>> result = {};
    notesMap.forEach((key, value) {
      result[key] = (value as List).map((noteJson) => VerseNote.fromJson(noteJson)).toList();
    });
    return result;
  }

  Future<void> saveNotes(Map<String, List<VerseNote>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> notesMap = {};
    notes.forEach((key, value) {
      notesMap[key] = value.map((note) => note.toJson()).toList();
    });
    await prefs.setString(_notesKey, jsonEncode(notesMap));
  }

  Future<Map<String, List<Highlight>>> getHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final highlightsJson = prefs.getString(_highlightsKey) ?? '{}';
    final Map<String, dynamic> highlightsMap = jsonDecode(highlightsJson);
    
    Map<String, List<Highlight>> result = {};
    highlightsMap.forEach((key, value) {
      result[key] = (value as List).map((highlightJson) => Highlight.fromJson(highlightJson)).toList();
    });
    return result;
  }

  Future<void> saveHighlights(Map<String, List<Highlight>> highlights) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> highlightsMap = {};
    highlights.forEach((key, value) {
      highlightsMap[key] = value.map((highlight) => highlight.toJson()).toList();
    });
    await prefs.setString(_highlightsKey, jsonEncode(highlightsMap));
  }
}