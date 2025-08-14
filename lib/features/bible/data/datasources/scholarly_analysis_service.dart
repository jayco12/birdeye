import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../domain/entities/verse.dart';

class ScholarlyAnalysisService {
  static const String _bibleHubBase = 'https://biblehub.com';
  
  Future<Map<String, dynamic>> getVerseAnalysis(Verse verse) async {
    try {
      final studyData = await _getBibleHubStudyPage(verse);
      return {
        'analysis': studyData['analysis'],
        'questions': studyData['questions'],
        'url': _getBibleHubStudyUrl(verse),
        'source': 'BibleHub Study Resources',
      };
    } catch (e) {
      return {
        'error': 'Failed to load analysis: $e',
        'url': _getBibleHubStudyUrl(verse),
      };
    }
  }

  Future<Map<String, dynamic>> _getBibleHubStudyPage(Verse verse) async {
    final url = _getBibleHubStudyUrl(verse);
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        
        // Extract study analysis
        String analysis = '';
        final studyContent = document.querySelector('.studynote');
        if (studyContent != null) {
          analysis = _cleanText(studyContent.text.trim());
        }
        
        // If no study note, try other selectors
        if (analysis.isEmpty) {
          final contentDiv = document.querySelector('.vheading')?.parent;
          if (contentDiv != null) {
            final paragraphs = contentDiv.querySelectorAll('p');
            final texts = paragraphs.map((p) => p.text.trim()).where((t) => t.isNotEmpty).take(3);
            analysis = texts.join('\n\n');
          }
        }
        
        return {
          'analysis': analysis.isNotEmpty ? analysis : 'Study content available at: $url',
          'questions': _generateContextualQuestions(verse),
        };
      }
    } catch (e) {
      // Return fallback
    }
    
    return {
      'analysis': 'View detailed study at: $url',
      'questions': _generateContextualQuestions(verse),
    };
  }

String _cleanText(String text) {
  return text
      .replaceAll(RegExp(r'\s+\n\s+'), '\n\n') 
      .replaceAll(RegExp(r'[^\w\s.,;:!?()-\n]'), '') 
      .trim();
}


  String _getBibleHubStudyUrl(Verse verse) {
    final bookName = _normalizeBookName(verse.bookName);
    return '$_bibleHubBase/study/$bookName/${verse.chapterNumber}-${verse.verseNumber}.htm';
  }

  String _normalizeBookName(String bookName) {
    final normalized = bookName.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('1', '1_')
        .replaceAll('2', '2_')
        .replaceAll('3', '3_');
    
    // Handle special cases
    final bookMappings = {
      'songofsolomon': 'songs',
      'songofsongsongs': 'songs',
      'ecclesiastes': 'ecclesiastes',
      '1chronicles': '1_chronicles',
      '2chronicles': '2_chronicles',
      '1kings': '1_kings',
      '2kings': '2_kings',
      '1samuel': '1_samuel',
      '2samuel': '2_samuel',
      '1timothy': '1_timothy',
      '2timothy': '2_timothy',
      '1peter': '1_peter',
      '2peter': '2_peter',
      '1john': '1_john',
      '2john': '2_john',
      '3john': '3_john',
      '1corinthians': '1_corinthians',
      '2corinthians': '2_corinthians',
      '1thessalonians': '1_thessalonians',
      '2thessalonians': '2_thessalonians',
    };
    
    return bookMappings[normalized] ?? normalized;
  }

  List<String> _generateContextualQuestions(Verse verse) {
    return [
      'What is the historical context of this passage?',
      'How does this verse relate to the surrounding chapter?',
      'What theological themes are present in this verse?',
      'How might this verse apply to modern Christian life?',
      'What was the original audience and their situation?',
      'What key words or phrases require deeper study?',
    ];
  }

  Future<List<String>> getStudyQuestions(Verse verse) async {
    return _generateContextualQuestions(verse);
  }
}