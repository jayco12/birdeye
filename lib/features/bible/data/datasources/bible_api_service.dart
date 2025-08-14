import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse_model.dart';
import 'offline_cache_service.dart';

class BibleApiService {
  final http.Client client;
  static const String baseUrl = 'https://birdeye.onrender.com';
final OfflineCacheService offlineCache = OfflineCacheService();

  BibleApiService(this.client);

  String _mapBookName(String input) {
    final normalized = input.trim().toLowerCase().replaceAll(' ', '_');

    final bookMap = {
      'gen': 'GEN',
      'exod': 'EXO',
      'lev': 'LEV',
      'num': 'NUM',
      'deut': 'DEU',
      'josh': 'JOS',
      'judg': 'JDG',
      'ruth': 'RUT',
      '1sam': '1SA',
      '2sam': '2SA',
      '1kgs': '1KI',
      '2kgs': '2KI',
      '1chr': '1CH',
      '2chr': '2CH',
      'ezra': 'EZR',
      'neh': 'NEH',
      'esth': 'EST',
      'job': 'JOB',
      'ps': 'PSA',
      'prov': 'PRO',
      'eccl': 'ECC',
      'song': 'SNG',
      'isa': 'ISA',
      'jer': 'JER',
      'lam': 'LAM',
      'ezek': 'EZK',
      'dan': 'DAN',
      'hos': 'HOS',
      'joel': 'JOL',
      'amos': 'AMO',
      'obad': 'OBA',
      'jonah': 'JON',
      'mic': 'MIC',
      'nah': 'NAM',
      'hab': 'HAG',
      'zeph': 'ZEP',
      'hab': 'HAB',
      'zech': 'ZEC',
      'mal': 'MAL',
      'matt': 'MAT',
      'mark': 'MRK',
      'luke': 'LUK',
      'john': 'JHN',
      'acts': 'ACT',
      'rom': 'ROM',
      '1cor': '1CO',
      '2cor': '2CO',
      'gal': 'GAL',
      'eph': 'EPH',
      'phil': 'PHP',
      'col': 'COL',
      '1thess': '1TH',
      '2thess': '2TH',
      '1tim': '1TIv',
      '2tim': '2TI',
      'titus': 'TIT',
      'phlm': 'PHM',
      'heb': 'HEB',
      'jas': 'JAS',
      '1pet': '1PE',
      '2pet': '2PE',
      '1john': '1JN',
      '2john': '2JN',
      '3john': '3JN',
      'jude': 'JUD',
      'rev': 'REV',
    };

    return bookMap[normalized] ?? normalized;
  }

Future<List<VerseModel>> fetchVerses(String query, String translation ) async {
  if (query.contains(':')) {
    return await _fetchSpecificVerse(query, translation);
  } else if (RegExp(r'^[A-Za-z0-9 ]+$').hasMatch(query.trim())) {
    return await _fetchChapterVerses(query, translation);
  } else {
    return await searchVerses(query);
  }
}
Uri _buildVerseUri(String book, int chapter, int verse, String translation) {
  final basePath = '$baseUrl/merged/$book/$chapter/$verse';
  if (translation.toUpperCase() == 'KJV') {
    return Uri.parse(basePath);
  }  else if (translation.toUpperCase() == 'BSB') {
    return Uri.parse('$baseUrl/books/BSB/$book/$chapter');

  }  else if (translation.toUpperCase() == 'ASV') {
    return Uri.parse('$baseUrl/books/eng_asv/$book/$chapter');

  }else if (translation.toUpperCase() == 'LSV') {
    return Uri.parse('$baseUrl/books/eng_lsv/$book/$chapter');

  }else {
    return Uri.parse('$baseUrl/merged/$book/$chapter/$verse');
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

  final url = _buildVerseUri(book, chapter, verse, translation);

  print('📖 Input: $reference → book="$book", chapter=$chapter, verse=$verse, translation=$translation');
  print('📚 Fetching from: $url');

  final response = await client.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('API response: $data');

    return [VerseModel.fromApi(data, translation, book, chapter, verse)];
    
  }

  return [];
}
Uri _buildChapterUri(String book, int chapter, String translation) {
  final basePath = '$baseUrl/merged/$book/$chapter';
  if (translation.toUpperCase() == 'KJV') {
    return Uri.parse(basePath);
  } 
  else if (translation.toUpperCase() == 'BSB') {
    return Uri.parse('$baseUrl/books/BSB/$book/$chapter');

  }  else if (translation.toUpperCase() == 'ASV') {
    return Uri.parse('$baseUrl/books/eng_asv/$book/$chapter');

  }else if (translation.toUpperCase() == 'LSV') {
    return Uri.parse('$baseUrl/books/eng_lsv/$book/$chapter');

  }else if (translation.toUpperCase() == 'NET') {
    return Uri.parse('$baseUrl/books/eng_net/$book/$chapter');

  }
  else{
    return Uri.parse('$baseUrl/merged/$book/$chapter');
  }
}
Future<List<VerseModel>> fetchChapter(String reference, String translation) async {
  final offlineService = OfflineCacheService();

  // 1️⃣ Try to load cached verses
  final cached = await offlineService.getCachedVerses(
    _mapBookNameFromReference(reference),
    _getChapterNumberFromReference(reference),
    translation,
  );

  if (cached.isNotEmpty) {
    print('📚 Loaded ${cached.length} verses from offline cache for $reference ($translation)');
    return cached;
  }

  // 2️⃣ Fetch from API
  final fetchedVerses = await _fetchChapterVerses(reference, translation);

  if (fetchedVerses.isNotEmpty) {
    // 3️⃣ Cache verses locally
    await offlineService.cacheVerses(fetchedVerses);

    // 4️⃣ Update chapter entry with verse count
    final bookAbbr = fetchedVerses.first.bookAbbreviation;
    final chapterNumber = fetchedVerses.first.chapterNumber;
    await offlineService.updateChapterVerseCount(bookAbbr, chapterNumber, fetchedVerses.length);

    print('🌐 Fetched ${fetchedVerses.length} verses from API and cached locally for $reference ($translation)');
  }

  return fetchedVerses;
}

// Helper to extract chapter number
int _getChapterNumberFromReference(String reference) {
  final parts = reference.split(' ');
  return int.tryParse(parts.last) ?? 1;
}

// Helper to map book name
String _mapBookNameFromReference(String reference) {
  final parts = reference.split(' ');
  final bookPart = parts.sublist(0, parts.length - 1).join(' ');
  return _mapBookName(bookPart);
}

Future<List<VerseModel>> _fetchChapterVerses(String query, String translation) async {
  final parts = query.trim().split(' ');
  final chapter = int.tryParse(parts.last) ?? 1;
  final bookPart = parts.sublist(0, parts.length - 1).join(' ');
  final book = _mapBookName(bookPart);

  final url = _buildChapterUri(book, chapter, translation);

  print('📖 Input: $query → book="$book", chapter=$chapter, translation=$translation');
  print('📚 Fetching from: $url');

  final response = await client.get(url);
  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    final versesData = decoded['verses'] as List<dynamic>;

    return versesData.map((v) {
      return VerseModel.fromApi(
        v,
        translation,
        book,
        chapter,
        v['verse_number'] as int? ?? 1,
      );
    }).toList();
  }

  return [];
}

String formatVerseText(String raw) {
  if (raw.isEmpty) return raw;

  // Fix multiple spaces and trim
  var cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Capitalize first letter
  cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);

  // Add punctuation if completely missing
  if (!cleaned.endsWith('.') &&
      !cleaned.endsWith('!') &&
      !cleaned.endsWith('?')) {
    cleaned += '.';
  }

  return cleaned;
}
Future<List<Map<String, dynamic>>> getBooksList() async {
  final url = Uri.parse('https://bible.helloao.org/api/eng_kjv/books.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(decoded['books']); // ✅ fix
  }
  throw Exception('Failed to load books list');
}
  Future<List<VerseModel>> search(String query, [String translation = 'KJV']) async {
    // 1️⃣ Try cache first
    final cached = await offlineCache.searchCachedVerses(query, translation);
    if (cached.isNotEmpty) {
      print('📦 Found ${cached.length} matches in offline cache');
      return cached;
    }

    // 2️⃣ Fallback to online search
    final online = await searchVerses(query); // your existing online search
    if (online.isNotEmpty) {
      print('💾 Caching ${online.length} verses to offline database');
      
      await offlineCache.cacheVerses(online);
    }

    return online;
  }
Future<List<VerseModel>> searchVerses(String query) async {
  print('🔍 Starting Bible search for: "$query"');

  final books = await getBooksList();
  print('📚 Loaded ${books.length} books from API');

  final results = <VerseModel>[];

for (var book in books) {
  final chapters = book['numberOfChapters'] as int? ?? 0;
  final bookName = book['name'];
  final abbreviation = book['id']; // use 'id' field, not 'abbr'

  print('📖 Searching $bookName ($chapters chapters)');

  final chapterFutures = List.generate(chapters, (i) async {
    final chapterNumber = i + 1;
    final chapterUrl = Uri.parse(
        'https://bible.helloao.org/api/eng_kjv/$abbreviation/$chapterNumber.json');
    
    print('⏳ Fetching $bookName $chapterNumber...');
    final chapterResponse = await http.get(chapterUrl);

    if (chapterResponse.statusCode != 200) {
      print('❌ Failed to load $bookName $chapterNumber');
      return;
    }

    final chapterData = jsonDecode(chapterResponse.body) as Map<String, dynamic>;
    final verses = chapterData['chapter']['content'] as List<dynamic>? ?? [];

    for (var verseData in verses) {
      if (verseData['type'] != 'verse') continue;

      final verseNumber = verseData['number'] as int? ?? 0;
      final verseTextList = verseData['content'] as List<dynamic>? ?? [];
      final verseText = verseTextList
          .whereType<String>()
          .join(' ')
          .trim();

      if (verseText.toLowerCase().contains(query.toLowerCase())) {
        print('✅ Found match in $bookName $chapterNumber:$verseNumber');
        results.add(VerseModel(
          bookName: bookName,
          bookAbbreviation: abbreviation,
          chapterNumber: chapterNumber,
          verseNumber: verseNumber,
          text: verseText,
          translation: 'KJV',
          reference: '$bookName $chapterNumber:$verseNumber',
          testament: VerseModel.getTestament(bookName),
        ));
      }
    }
  });

  await Future.wait(chapterFutures);
}

print('🏁 Search complete — ${results.length} matches found');
return results;
}
  Future<List<String>> getAvailableTranslations() async {
    return ['NET', 'KJV', 'LSV', 'NIV', 'BSB', 'ASV'];
  }
  
}
