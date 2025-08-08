import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/verse_model.dart';
import '../../../../core/config/api_keys.dart';

class VerseOfDayService {
  static const String baseUrl = 'https://biblesdk.com';
  
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

  static Future<Map<String, dynamic>> getVerseOfDay() async {
    try {
      // Generate random verse reference
      final random = Random();
      final bookKeys = bibleBooks.keys.toList();
      final randomBook = bookKeys[random.nextInt(bookKeys.length)];
      final maxChapter = bibleBooks[randomBook]!;
      final randomChapter = random.nextInt(maxChapter) + 1;
      
      // Fetch verse
      final verse = await _fetchRandomVerse(randomBook, randomChapter);
      if (verse == null) return {};
      
      // Generate insight
      final insight = await _generateInsight(verse.text, verse.reference);
      
      return {
        'verse': verse,
        'insight': insight,
      };
    } catch (e) {
      print('Error getting verse of day: $e');
      return {};
    }
  }

  static Future<VerseModel?> _fetchRandomVerse(String book, int chapter) async {
    try {
      final url = Uri.parse('$baseUrl/api/books/$book/chapters/$chapter/verses?concordance=true&take=100');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final phrases = data['phrases'] as List;
        
        // Group phrases by verse
        final verseMap = <int, List<Map<String, dynamic>>>{};
        for (final phrase in phrases) {
          if (phrase['verse'] != null && phrase['usfm'] != null) {
            final usfm = phrase['usfm'] as List;
            if (usfm.contains('v') || usfm.contains('w')) {
              final verseNum = phrase['verse'] as int;
              verseMap.putIfAbsent(verseNum, () => []);
              verseMap[verseNum]!.add(phrase as Map<String, dynamic>);
            }
          }
        }
        
        if (verseMap.isNotEmpty) {
          // Pick random verse from chapter
          final verseNumbers = verseMap.keys.toList();
          final randomVerseNum = verseNumbers[Random().nextInt(verseNumbers.length)];
          
          return VerseModel.fromBibleSdkVerse({
            'phrases': verseMap[randomVerseNum]
          }, 'NET', book, chapter, randomVerseNum);
        }
      }
    } catch (e) {
      print('Error fetching verse: $e');
    }
    return null;
  }

  static Future<String> _generateInsight(String verseText, String reference) async {
    try {
      final prompt = '''Provide a concise spiritual insight for this Bible verse (2-3 sentences max):
"$verseText" ($reference)

Focus on:
- Key spiritual principle or lesson
- Practical application for daily life
- Encouragement or wisdom for today''';

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${ApiKeys.geminiApiKey}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 150}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      }
    } catch (e) {
      print('Error generating insight: $e');
    }
    
    return 'Reflect on this verse and let God\'s word speak to your heart today.';
  }
}