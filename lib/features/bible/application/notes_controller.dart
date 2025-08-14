import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/contribution_model.dart';
import '../domain/entities/verse.dart';
import '../domain/entities/highlight.dart';
import '../data/datasources/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../presentation/screens/all_notes_screen.dart';

class NotesController extends GetxController {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxMap<String, List<VerseNote>> verseNotes = <String, List<VerseNote>>{}.obs;
  final RxMap<String, List<Highlight>> verseHighlights = <String, List<Highlight>>{}.obs;
  final LocalStorage _localStorage = LocalStorage();
  final RxMap<String, List<VerseContribution>> verseContributions = <String, List<VerseContribution>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _listenToContributions();
  }
void _listenToContributions() {
    _firestore.collection('verse_contributions').snapshots().listen((snapshot) {
      final Map<String, List<VerseContribution>> contributionsMap = {};
      for (var doc in snapshot.docs) {
        final contribution = VerseContribution.fromMap(doc.data());
        contributionsMap.putIfAbsent(contribution.verseReference, () => []).add(contribution);
      }
      verseContributions.assignAll(contributionsMap);
    });
  }

  Future<void> addContribution(String verseReference, String content, String contributorName) async {
    final newId = _firestore.collection('verse_contributions').doc().id;
    final contribution = VerseContribution(
      id: newId,
      verseReference: verseReference,
      content: content,
      contributorName: contributorName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore.collection('verse_contributions').doc(newId).set(contribution.toMap());
      // Local update is automatic via the snapshot listener (_listenToContributions)
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit contribution: $e');
    }
  }

  Future<void> deleteContribution(String contributionId, String reference) async {
    try {
      await _firestore.collection('verse_contributions').doc(contributionId).delete();
      // Local update is automatic via snapshot listener
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete contribution: $e');
    }
  }
Future<void> _submitContributionToBackend(VerseContribution contribution) async {
  final url = Uri.parse('https://yourbackend.example.com/contributions');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'verseReference': contribution.verseReference,
        'content': contribution.content,
        'contributorName': contribution.contributorName,
        'createdAt': contribution.createdAt.toIso8601String(),
        'updatedAt': contribution.updatedAt.toIso8601String(),
        'id': contribution.id,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit contribution');
    }
  } catch (e) {
    // You may want to queue retry or notify user
    print('Error submitting contribution: $e');
  }
}
  Future<void> _loadData() async {
    final notes = await _localStorage.getNotes();
    final highlights = await _localStorage.getHighlights();
    verseNotes.assignAll(notes);
    verseHighlights.assignAll(highlights);
  }

  void addNote(String verseReference, String content) async {
    final note = VerseNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (verseNotes[verseReference] == null) {
      verseNotes[verseReference] = [];
    }
    verseNotes[verseReference]!.add(note);
    await _localStorage.saveNotes(verseNotes);
    
    // Auto-save if enabled
    await _checkAutoSave(verseReference);
  }

  void addHighlight(String verseReference, int startIndex, int endIndex, HighlightColor color) async {
    final highlight = Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      verseReference: verseReference,
      startIndex: startIndex,
      endIndex: endIndex,
      color: color,
      createdAt: DateTime.now(),
    );

    if (verseHighlights[verseReference] == null) {
      verseHighlights[verseReference] = [];
    }
    verseHighlights[verseReference]!.add(highlight);
    await _localStorage.saveHighlights(verseHighlights);
  }

  Future<void> exportToNativeNotes(Verse verse) async {
    try {
      final notes = verseNotes[verse.reference] ?? [];
      final highlights = verseHighlights[verse.reference] ?? [];
      
      String exportContent = _formatExportContent(verse, notes, highlights);
      
      await Share.share(
        exportContent,
        subject: '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} - Bible Study Notes',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to export notes: ${e.toString()}');
    }
  }

  String _formatExportContent(Verse verse, List<VerseNote> notes, List<Highlight> highlights) {
    StringBuffer content = StringBuffer();
    
    content.writeln('📖 ${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} (${verse.translation})');
    content.writeln();
    content.writeln('"${verse.text}"');
    content.writeln();
    
    if (highlights.isNotEmpty) {
      content.writeln('🎨 Highlights:');
      for (var highlight in highlights) {
        final highlightedText = verse.text.substring(highlight.startIndex, highlight.endIndex);
        content.writeln('• ${highlight.color.name.toUpperCase()}: "$highlightedText"');
      }
      content.writeln();
    }
    
    if (notes.isNotEmpty) {
      content.writeln('📝 My Notes:');
      for (var note in notes) {
        content.writeln('• ${note.content}');
        content.writeln('  (${_formatDate(note.createdAt)})');
      }
      content.writeln();
    }
    
    content.writeln('Generated by Blackbird Bible App');
    
    return content.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }



  List<VerseNote> getNotesForVerse(String reference) {
    return verseNotes[reference] ?? [];
  }

  List<Highlight> getHighlightsForVerse(String reference) {
    return verseHighlights[reference] ?? [];
  }

  void deleteNote(String noteId, String verseReference) async {
    verseNotes[verseReference]?.removeWhere((note) => note.id == noteId);
    await _localStorage.saveNotes(verseNotes);
  }

  void deleteHighlight(String highlightId, String verseReference) async {
    verseHighlights[verseReference]?.removeWhere((highlight) => highlight.id == highlightId);
    await _localStorage.saveHighlights(verseHighlights);
  }

  Future<void> _checkAutoSave(String verseReference) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoSave = prefs.getBool('autoSaveNotes') ?? false;
      
      if (autoSave) {
        // Find the verse by reference and auto-export
        final notes = verseNotes[verseReference] ?? [];
        final highlights = verseHighlights[verseReference] ?? [];
        
        if (notes.isNotEmpty || highlights.isNotEmpty) {
          // Create a minimal verse object for export
          final parts = verseReference.split(' ');
          if (parts.length >= 2) {
            // final bookChapter = parts.sublist(0, parts.length - 1).join(' ');
            // final verseNum = parts.last;
            
            String exportContent = _formatAutoSaveContent(verseReference, notes, highlights);
            
            await Share.share(
              exportContent,
              subject: '$verseReference - Bible Study Notes',
            );
          }
        }
      }
    } catch (e) {
      // Silently fail auto-save
    }
  }

  String _formatAutoSaveContent(String reference, List<VerseNote> notes, List<Highlight> highlights) {
    StringBuffer content = StringBuffer();
    
    content.writeln('📖 $reference');
    content.writeln();
    
    if (highlights.isNotEmpty) {
      content.writeln('🎨 Highlights:');
      for (var highlight in highlights) {
        content.writeln('• ${highlight.color.name.toUpperCase()}');
      }
      content.writeln();
    }
    
    if (notes.isNotEmpty) {
      content.writeln('📝 Notes:');
      for (var note in notes) {
        content.writeln('• ${note.content}');
      }
      content.writeln();
    }
    
    content.writeln('Auto-saved by Blackbird Bible App');
    
    return content.toString();
  }
}