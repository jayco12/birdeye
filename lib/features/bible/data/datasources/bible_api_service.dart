import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse_model.dart';

class BibleApiService {
  final http.Client client;
  static const String baseUrl = 'https://biblesdk.com';

  BibleApiService(this.client);

  String _mapBookName(String input) {
    final cleanInput = input.toUpperCase().replaceAll(' ', '');
    
    // If input is 4+ characters, try mapping first 4 chars to 3-char code
    if (cleanInput.length >= 4) {
      final first4 = cleanInput.substring(0, 4);
      final first3 = cleanInput.substring(0, 3);
      
      // Check if first 4 chars map to a known book
      final fourCharMap = {
        'GENE': 'GEN', 'EXOD': 'EXO', 'LEVI': 'LEV', 'NUMB': 'NUM',
        'DEUT': 'DEU', 'JOSH': 'JOS', 'JUDG': 'JDG', 'RUTH': 'RUT',
        '1SAM': '1SA', '2SAM': '2SA', '1KIN': '1KI', '2KIN': '2KI',
        '1CHR': '1CH', '2CHR': '2CH', 'EZRA': 'EZR', 'NEHE': 'NEH',
        'ESTH': 'EST', 'PSAL': 'PSA', 'PROV': 'PRO', 'ECCL': 'ECC',
        'SONG': 'SNG', 'ISAI': 'ISA', 'JERE': 'JER', 'LAME': 'LAM',
        'EZEK': 'EZK', 'DANI': 'DAN', 'HOSE': 'HOS', 'JOEL': 'JOL',
        'AMOS': 'AMO', 'OBAD': 'OBA', 'JONA': 'JON', 'MICA': 'MIC',
        'NAHU': 'NAM', 'HABA': 'HAB', 'ZEPH': 'ZEP', 'HAGG': 'HAG',
        'ZECH': 'ZEC', 'MALA': 'MAL', 'MATT': 'MAT', 'MARK': 'MRK',
        'LUKE': 'LUK', 'JOHN': 'JHN', 'ACTS': 'ACT', 'ROMA': 'ROM',
        '1COR': '1CO', '2COR': '2CO', 'GALA': 'GAL', 'EPHE': 'EPH',
        'PHIL': 'PHP', 'COLO': 'COL', '1THE': '1TH', '2THE': '2TH',
        '1TIM': '1TI', '2TIM': '2TI', 'TITU': 'TIT', 'PHILE': 'PHM',
        'HEBR': 'HEB', 'JAME': 'JAS', '1PET': '1PE', '2PET': '2PE',
        '1JOH': '1JN', '2JOH': '2JN', '3JOH': '3JN', 'JUDE': 'JUD',
        'REVE': 'REV',
      };
      
      if (fourCharMap.containsKey(first4)) {
        return fourCharMap[first4]!;
      }
      
      // If no 4-char match, return first 3 chars
      return first3;
    }
    
    // For shorter inputs, return as-is (already uppercase)
    return cleanInput;
  }

  Future<List<VerseModel>> fetchVerses(String query, {String translation = 'NET'}) async {
    try {
      print('🔍 Fetching verses for query: $query');
      if (query.contains(':')) {
        return await _fetchSpecificVerse(query, translation);
      } else if (RegExp(r'^[A-Za-z0-9]+ \d+$').hasMatch(query.trim())) {
        return await _fetchChapterVerses(query, translation);
      } else {
        return await _searchVerses(query, translation);
      }
    } catch (e) {
      print('❌ API request failed: $e');
      throw Exception('API request failed: $e');
    }
  }

  Future<List<VerseModel>> _fetchSpecificVerse(String reference, String translation) async {
    final parts = reference.split(':');
    if (parts.length != 2) throw Exception('Invalid reference format');
    
    final bookChapter = parts[0].trim();
    final verse = int.tryParse(parts[1].trim()) ?? 1;
    
    final bookParts = bookChapter.split(' ');
    final chapter = int.tryParse(bookParts.last) ?? 1;
    final bookPart = bookParts.sublist(0, bookParts.length - 1).join(' ');
    final book = _mapBookName(bookPart);

    final url = Uri.parse('$baseUrl/api/books/$book/chapters/$chapter/verses/$verse?concordance=true');
    print('📡 Fetching verse from: $url');
    final response = await client.get(url);
    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return [VerseModel.fromBibleSdkVerse(data, translation, book, chapter, verse)];
    }
    return [];
  }

  Future<List<VerseModel>> _fetchChapterVerses(String query, String translation) async {
    final parts = query.trim().split(' ');
    final chapter = int.tryParse(parts.last) ?? 1;
    final bookPart = parts.sublist(0, parts.length - 1).join(' ');
    final book = _mapBookName(bookPart);
    
    print('📖 Input: $bookPart → Mapped book: $book, chapter: $chapter');

    final allPhrases = <Map<String, dynamic>>[];
    int take = 1000;
    int cursor = 1;
    bool hasMore = true;
    
    while (hasMore && take <= 10000) {
      final url = '$baseUrl/api/books/$book/chapters/$chapter/verses?concordance=true&take=$take&cursor=$cursor';
      print('📚 Fetching from: $url');
      final response = await client.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📄 Response data keys: ${data.keys.toList()}');
        
        if (data['phrases'] != null) {
          final phrases = (data['phrases'] as List).cast<Map<String, dynamic>>();
          print('📝 Got ${phrases.length} phrases');
          allPhrases.addAll(phrases);
          
          // Use next link from API response for proper pagination
          if (data['links']?['next'] != null) {
            final nextLink = data['links']['next'] as String;
            cursor = int.tryParse(RegExp(r'cursor=(\d+)').firstMatch(nextLink)?.group(1) ?? '0') ?? cursor + take;
          } else {
            hasMore = false;
          }
        } else {
          hasMore = false;
        }
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        break;
      }
    }

    print('📁 Total phrases collected: ${allPhrases.length}');
    final verseMap = <int, List<Map<String, dynamic>>>{};
    
    for (final phrase in allPhrases) {
      if (phrase['verse'] != null) {
        final verseNum = phrase['verse'] as int;
        verseMap.putIfAbsent(verseNum, () => []);
        verseMap[verseNum]!.add(phrase);
      }
    }
    
    print('📝 Found ${verseMap.length} verses: ${verseMap.keys.toList()}');
    
    final verses = <VerseModel>[];
    final sortedEntries = verseMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    for (final entry in sortedEntries) {
      verses.add(VerseModel.fromBibleSdkVerse({
        'phrases': entry.value
      }, translation, book, chapter, entry.key));
    }
    return verses;
  }

  Future<List<VerseModel>> _searchVerses(String query, String translation) async {
    final url = Uri.parse('$baseUrl/api/search?query=${Uri.encodeComponent(query)}&concordance=true');
    print('🔍 Searching verses from: $url');
    final response = await client.get(url);
    print('📊 Search response status: ${response.statusCode}');
    print('📄 Search response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null) {
        final results = data['results'] as List;
        return results
            .map((r) => VerseModel.fromBibleSdkSearch(r as Map<String, dynamic>, translation))
            .toList();
      }
    }
    return [];
  }

  Future<List<String>> getAvailableTranslations() async {
    return ['NET', 'KJV', 'ESV', 'NIV', 'NASB', 'NLT'];
  }
}
