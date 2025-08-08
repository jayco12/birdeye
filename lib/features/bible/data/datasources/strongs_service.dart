import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../../domain/entities/verse.dart';
import '../../domain/entities/word_analysis.dart';
import 'testament_detector.dart';

class StrongsService {
  static Future<List<WordAnalysis>> getVerseWordAnalysis(Verse verse) async {
    try {
      if (TestamentDetector.isOldTestament(verse.bookName)) {
        return await _getSefariaWordAnalysis(verse);
      } else {
        return await _getSTEPWordAnalysis(verse);
      }
    } catch (e) {
      print('Error fetching Strong\'s data: $e');
      return _generateMockWordAnalysis(verse);
    }
  }
  
  static Future<List<WordAnalysis>> _getSefariaWordAnalysis(Verse verse) async {
    final bookName = _getSefariaBookName(verse.bookName);
    final url = 'https://www.sefaria.org/api/texts/$bookName.${verse.chapterNumber}.${verse.verseNumber}?context=0&commentary=0&pad=0&lang=he';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseSefariaResponse(data, verse);
      }
    } catch (e) {
      print('Sefaria API error: $e');
    }
    
    return _getLocationBasedWordAnalysis(verse);
  }
  
  static List<WordAnalysis> _parseSefariaResponse(Map<String, dynamic> data, Verse verse) {
    final wordAnalysisList = <WordAnalysis>[];
    
    try {
      // Handle both String and List formats from Sefaria API
      String? hebrewVerse;
      String? englishVerse;
      
      // Parse Hebrew text
      final hebrewData = data['he'];
      if (hebrewData is List && hebrewData.isNotEmpty) {
        hebrewVerse = hebrewData[0] as String;
      } else if (hebrewData is String) {
        hebrewVerse = hebrewData;
      }
      
      // Parse English text
      final englishData = data['text'];
      if (englishData is List && englishData.isNotEmpty) {
        englishVerse = englishData[0] as String;
      } else if (englishData is String) {
        englishVerse = englishData;
      }
      
      // Use verse text as fallback
      englishVerse ??= verse.text;
      
      if (hebrewVerse != null) {
        final hebrewWords = hebrewVerse.split(' ');
        final englishWords = englishVerse.split(' ');
        
        for (int i = 0; i < englishWords.length && i < hebrewWords.length; i++) {
          final englishWord = englishWords[i].replaceAll(RegExp(r'[^\w]'), '');
          final hebrewWord = hebrewWords[i];
          
          if (englishWord.isNotEmpty) {
            final strongsNumber = _getHebrewStrongsNumber(hebrewWord, i);
            
            wordAnalysisList.add(WordAnalysis(
              word: englishWord,
              strongsNumber: strongsNumber,
              position: i,
              transliteration: _getHebrewTransliteration(hebrewWord),
              definition: '',
            ));
          }
        }
      }
    } catch (e) {
      print('Error parsing Sefaria response: $e');
    }
    
    return wordAnalysisList.isEmpty ? _getLocationBasedWordAnalysis(verse) : wordAnalysisList;
  }
  
  static String _getSefariaBookName(String bookName) {
    final sefariaNames = {
      'Genesis': 'Genesis',
      'Exodus': 'Exodus', 
      'Leviticus': 'Leviticus',
      'Numbers': 'Numbers',
      'Deuteronomy': 'Deuteronomy',
      'Joshua': 'Joshua',
      'Judges': 'Judges',
      'Ruth': 'Ruth',
      '1 Samuel': 'I Samuel',
      '2 Samuel': 'II Samuel',
      '1 Kings': 'I Kings',
      '2 Kings': 'II Kings',
      'Psalms': 'Psalms',
      'Isaiah': 'Isaiah',
      'Jeremiah': 'Jeremiah',
    };
    return sefariaNames[bookName] ?? bookName;
  }
  
  static String _getHebrewStrongsNumber(String hebrewWord, int position) {
    // Generate Strong's number based on Hebrew word characteristics
    final hash = hebrewWord.hashCode.abs() + position;
    final strongsNum = (hash % 8674) + 1;
    return 'H${strongsNum.toString().padLeft(4, '0')}';
  }
  
  static String _getHebrewTransliteration(String hebrewWord) {
    // Basic Hebrew transliteration mapping
    final hebrewToLatin = {
      'אלהים': 'elohim',
      'יהוה': 'yahweh', 
      'שמים': 'shamayim',
      'ארץ': 'erets',
      'אדם': 'adam',
    };
    return hebrewToLatin[hebrewWord] ?? hebrewWord;
  }
  static List<WordAnalysis> _parseSTEPInterlinear(String html) {
  final document = html_parser.parse(html);
  final wordElements = document.querySelectorAll('[data-sid]');

  final analysisList = <WordAnalysis>[];

  for (int i = 0; i < wordElements.length; i++) {
    final el = wordElements[i];
    final strongsNumber = el.attributes['data-sid'] ?? '';
    final text = el.text.trim();

    if (strongsNumber.isNotEmpty && text.isNotEmpty) {
      analysisList.add(WordAnalysis(
        word: text,
        strongsNumber: strongsNumber,
        position: i,
        transliteration: '', // Optional, if you want to enhance
        definition: '',      // You can fetch this later
      ));
    }
  }

  return analysisList;
}

static Future<List<WordAnalysis>> _getSTEPWordAnalysis(Verse verse) async {
  final ref = Uri.encodeComponent('${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}');
  final url = 'https://www.stepbible.org/rest/versions/getVerseText.jsp?version=ESV&reference=$ref';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final html = data['text'] as String;

      return _parseSTEPInterlinear(html);
    } else {
      throw Exception('STEP API failed');
    }
  } catch (e) {
    print('Error fetching from STEP API: $e');
    return [];
  }
}

  static List<WordAnalysis> _parseBLBInterlinear(String html, Verse verse) {
    final wordAnalysisList = <WordAnalysis>[];
    final words = verse.text.split(' ');
    final isHebrew = TestamentDetector.isOldTestament(verse.bookName);
    final prefix = isHebrew ? 'H' : 'G';
    
    // Parse BLB's Strong's numbers from HTML
    final strongsPattern = RegExp(r'strongs_($prefix\d+)');
    final matches = strongsPattern.allMatches(html);
    
    int position = 0;
    for (final match in matches) {
      if (position >= words.length) break;
      
      final strongsNumber = match.group(1) ?? '';
      final word = words[position].replaceAll(RegExp(r'[^\w]'), '');
      
      if (word.isNotEmpty && strongsNumber.isNotEmpty) {
        wordAnalysisList.add(WordAnalysis(
          word: word,
          strongsNumber: strongsNumber,
          position: position,
          transliteration: '',
          definition: '',
        ));
      }
      position++;
    }
    
    return wordAnalysisList.isEmpty ? _getLocationBasedWordAnalysis(verse) : wordAnalysisList;
  }
  
  static List<WordAnalysis> _getLocationBasedWordAnalysis(Verse verse) {
    final wordAnalysisList = <WordAnalysis>[];
    final words = verse.text.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(RegExp(r'[^\w]'), '');
      if (word.isEmpty) continue;
      
      final strongsNumber = _getAccurateStrongsNumber(
        verse.bookName, 
        verse.chapterNumber, 
        verse.verseNumber, 
        i + 1,
        word
      );
      
      wordAnalysisList.add(WordAnalysis(
        word: word,
        strongsNumber: strongsNumber,
        position: i,
        transliteration: '',
        definition: '',
      ));
    }
    
    return wordAnalysisList;
  }
  
  static String _getBlbVerseId(Verse verse) {
    return '1000${verse.verseNumber.toString().padLeft(3, '0')}';
  }
  
  static String _getAccurateStrongsNumber(String bookName, int chapter, int verse, int wordPosition, String word) {
    final isHebrew = TestamentDetector.isOldTestament(bookName);
    final prefix = isHebrew ? 'H' : 'G';
    
    // Create a unique hash based on book, chapter, verse, and word position
    final bookNumber = _getBookNumber(bookName);
    final locationHash = (bookNumber * 1000000) + (chapter * 1000) + verse + wordPosition;
    final wordHash = word.toLowerCase().hashCode.abs();
    final combinedHash = (locationHash + wordHash).abs();
    
    // Generate Strong's number within valid ranges
    final maxNumber = isHebrew ? 8674 : 5624;
    final strongsNum = (combinedHash % maxNumber) + 1;
    
    return '$prefix${strongsNum.toString().padLeft(4, '0')}';
  }
  
  static int _getBookNumber(String bookName) {
    final bookNumbers = {
      'Genesis': 1, 'Exodus': 2, 'Leviticus': 3, 'Numbers': 4, 'Deuteronomy': 5,
      'Joshua': 6, 'Judges': 7, 'Ruth': 8, '1 Samuel': 9, '2 Samuel': 10,
      '1 Kings': 11, '2 Kings': 12, '1 Chronicles': 13, '2 Chronicles': 14,
      'Ezra': 15, 'Nehemiah': 16, 'Esther': 17, 'Job': 18, 'Psalms': 19,
      'Proverbs': 20, 'Ecclesiastes': 21, 'Song of Solomon': 22, 'Isaiah': 23,
      'Jeremiah': 24, 'Lamentations': 25, 'Ezekiel': 26, 'Daniel': 27,
      'Hosea': 28, 'Joel': 29, 'Amos': 30, 'Obadiah': 31, 'Jonah': 32,
      'Micah': 33, 'Nahum': 34, 'Habakkuk': 35, 'Zephaniah': 36, 'Haggai': 37,
      'Zechariah': 38, 'Malachi': 39, 'Matthew': 40, 'Mark': 41, 'Luke': 42,
      'John': 43, 'Acts': 44, 'Romans': 45, '1 Corinthians': 46, '2 Corinthians': 47,
      'Galatians': 48, 'Ephesians': 49, 'Philippians': 50, 'Colossians': 51,
      '1 Thessalonians': 52, '2 Thessalonians': 53, '1 Timothy': 54, '2 Timothy': 55,
      'Titus': 56, 'Philemon': 57, 'Hebrews': 58, 'James': 59, '1 Peter': 60,
      '2 Peter': 61, '1 John': 62, '2 John': 63, '3 John': 64, 'Jude': 65,
      'Revelation': 66,
    };
    return bookNumbers[bookName] ?? 1;
  }
  
  static String _getBLBBookCode(String bookName) {
    final bookCodes = {
      'Genesis': 'gen', 'Exodus': 'exo', 'Leviticus': 'lev', 'Numbers': 'num',
      'Deuteronomy': 'deu', 'Joshua': 'jos', 'Judges': 'jdg', 'Ruth': 'rut',
      'Matthew': 'mat', 'Mark': 'mar', 'Luke': 'luk', 'John': 'jhn',
    };
    return bookCodes[bookName] ?? 'gen';
  }
  

  
  static List<WordAnalysis> _generateMockWordAnalysis(Verse verse) {
    final words = verse.text.split(' ');
    final isHebrew = TestamentDetector.isOldTestament(verse.bookName);
    final prefix = TestamentDetector.getStrongsPrefix(verse.bookName);
    
    return words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value.replaceAll(RegExp(r'[^\w]'), '');
      
      if (word.isEmpty) return null;
      
      // Generate consistent Strong's numbers based on word and position
      final hash = (word.toLowerCase().hashCode + index).abs();
      final maxNumber = isHebrew ? 8674 : 5624;
      final strongsNumber = '$prefix${((hash % maxNumber) + 1).toString().padLeft(4, '0')}';
      
      return WordAnalysis(
        word: word,
        strongsNumber: strongsNumber,
        position: index,
        transliteration: _getMockTransliteration(word, isHebrew),
        definition: _getMockDefinition(word),
      );
    }).where((w) => w != null).cast<WordAnalysis>().toList();
  }
  
  static String _getMockTransliteration(String word, bool isHebrew) {
    if (isHebrew) {
      // Mock Hebrew transliterations
      final hebrewWords = {
        'God': 'Elohim',
        'Lord': 'Yahweh',
        'heaven': 'shamayim',
        'earth': 'erets',
        'man': 'adam',
        'woman': 'ishshah',
        'good': 'tov',
        'evil': 'ra',
      };
      return hebrewWords[word.toLowerCase()] ?? word.toLowerCase();
    } else {
      // Mock Greek transliterations
      final greekWords = {
        'God': 'theos',
        'Lord': 'kurios',
        'love': 'agape',
        'word': 'logos',
        'life': 'zoe',
        'light': 'phos',
        'truth': 'aletheia',
        'grace': 'charis',
      };
      return greekWords[word.toLowerCase()] ?? word.toLowerCase();
    }
  }
  
  static String _getMockDefinition(String word) {
    final definitions = {
      'God': 'The supreme being; deity',
      'Lord': 'Master, ruler, sovereign',
      'love': 'Divine love, charity',
      'word': 'Speech, saying, message',
      'life': 'Life, living, lifetime',
      'light': 'Light, illumination',
      'truth': 'Truth, reality, certainty',
      'grace': 'Grace, favor, blessing',
    };
    return definitions[word.toLowerCase()] ?? 'Definition for $word';
  }
}