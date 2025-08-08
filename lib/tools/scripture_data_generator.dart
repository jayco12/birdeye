import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ScriptureDataGenerator {
  final http.Client client;
  final String geminiApiKey;
  
  ScriptureDataGenerator(this.client, this.geminiApiKey);

  // Bible books with chapter counts
  static const Map<String, int> bibleBooks = {
    'GEN': 50, 'EXO': 40, 'LEV': 27, 'NUM': 36, 'DEU': 34,
    'JOS': 24, 'JDG': 21, 'RUT': 4, '1SA': 31, '2SA': 24,
    '1KI': 22, '2KI': 25, '1CH': 29, '2CH': 36, 'EZR': 10,
    'NEH': 13, 'EST': 10, 'JOB': 42, 'PSA': 150, 'PRO': 31,
    'ECC': 12, 'SNG': 8, 'ISA': 66, 'JER': 52, 'LAM': 5,
    'EZK': 48, 'DAN': 12, 'HOS': 14, 'JOL': 3, 'AMO': 9,
    'OBA': 1, 'JON': 4, 'MIC': 7, 'NAM': 3, 'HAB': 3,
    'ZEP': 3, 'HAG': 2, 'ZEC': 14, 'MAL': 4, 'MAT': 28,
    'MRK': 16, 'LUK': 24, 'JHN': 21, 'ACT': 28, 'ROM': 16,
    '1CO': 16, '2CO': 13, 'GAL': 6, 'EPH': 6, 'PHP': 4,
    'COL': 4, '1TH': 5, '2TH': 3, '1TI': 6, '2TI': 4,
    'TIT': 3, 'PHM': 1, 'HEB': 13, 'JAS': 5, '1PE': 5,
    '2PE': 3, '1JN': 5, '2JN': 1, '3JN': 1, 'JUD': 1, 'REV': 22,
  };

  Future<void> generateAllScriptureData() async {
    final allData = <Map<String, dynamic>>[];
    
    for (final entry in bibleBooks.entries) {
      final book = entry.key;
      final chapters = entry.value;
      
      print('Processing $book ($chapters chapters)...');
      
      for (int chapter = 1; chapter <= chapters; chapter++) {
        try {
          final verses = await _fetchChapterVerses(book, chapter);
          
          for (final verse in verses) {
            final insights = await _generateInsights(verse['text']);
            final questions = await _generateStudyQuestions(verse['text']);
            final wordAnalysis = await _generateWordAnalysis(verse['text'], book, chapter, verse['verse']);
            
            allData.add({
              'book': book,
              'chapter': chapter,
              'verse': verse['verse'],
              'text': verse['text'],
              'insights': insights,
              'study_questions': questions,
              'word_analysis': wordAnalysis,
              'generated_at': DateTime.now().toIso8601String(),
            });
          }
          
          // Save progress every chapter
          await _saveProgress(allData, '$book-$chapter');
          
        } catch (e) {
          print('Error processing $book $chapter: $e');
        }
      }
    }
    
    // Save final complete dataset
    await _saveFinalData(allData);
  }

  Future<List<Map<String, dynamic>>> _fetchChapterVerses(String book, int chapter) async {
    final url = 'https://biblesdk.com/api/books/$book/chapters/$chapter/verses?concordance=true';
    final response = await client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final phrases = (data['phrases'] as List).cast<Map<String, dynamic>>();
      
      final verseMap = <int, List<Map<String, dynamic>>>{};
      for (final phrase in phrases) {
        if (phrase['verse'] != null) {
          final verseNum = phrase['verse'] as int;
          verseMap.putIfAbsent(verseNum, () => []);
          verseMap[verseNum]!.add(phrase);
        }
      }
      
      return verseMap.entries.map((entry) => {
        'verse': entry.key,
        'text': entry.value.map((p) => p['text']).join(' '),
      }).toList();
    }
    
    return [];
  }

  Future<String> _generateInsights(String verseText) async {
    final prompt = '''
Provide a concise spiritual insight for this Bible verse (2-3 sentences max):
"$verseText"

Focus on:
- Key spiritual principle or lesson
- Practical application for daily life
- Historical or cultural context if relevant
''';

    return await _callGemini(prompt);
  }

  Future<List<String>> _generateStudyQuestions(String verseText) async {
    final prompt = '''
Generate 3 thoughtful study questions for this Bible verse:
"$verseText"

Questions should:
- Encourage deep reflection
- Be applicable to modern life
- Vary in difficulty (basic understanding, application, deeper analysis)

Return as JSON array of strings.
''';

    final response = await _callGemini(prompt);
    try {
      return (jsonDecode(response) as List).cast<String>();
    } catch (e) {
      // Fallback if JSON parsing fails
      return response.split('\n').where((q) => q.trim().isNotEmpty).toList();
    }
  }

  Future<List<Map<String, String>>> _generateWordAnalysis(String verseText, String book, int chapter, int verse) async {
    final prompt = '''
Analyze significant Greek/Hebrew words in this Bible verse for unique or notable usage:
"$verseText" ($book $chapter:$verse)

Identify words with:
- Different meanings from typical usage (like "allos" vs "heteros" for "another")
- Theological significance
- Cultural/historical context
- Original language nuances lost in translation

Return as JSON array: [{"word": "english_word", "original": "greek/hebrew", "analysis": "explanation"}]
Return empty array [] if no significant words found.
''';

    final response = await _callGemini(prompt);
    try {
      return (jsonDecode(response) as List).cast<Map<String, dynamic>>().map((item) => {
        'word': item['word'] as String,
        'original': item['original'] as String,
        'analysis': item['analysis'] as String,
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> _callGemini(String prompt) async {
    final response = await client.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': prompt}]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 200,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    }
    
    throw Exception('Gemini API error: ${response.statusCode}');
  }

  Future<void> _saveProgress(List<Map<String, dynamic>> data, String checkpoint) async {
    final file = File('scripture_data_progress_$checkpoint.json');
    await file.writeAsString(jsonEncode(data));
    print('Progress saved: ${data.length} entries');
  }

  Future<void> _saveFinalData(List<Map<String, dynamic>> data) async {
    final file = File('complete_scripture_data.json');
    await file.writeAsString(jsonEncode(data));
    print('Complete dataset saved: ${data.length} total entries');
  }
}