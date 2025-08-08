import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/verse.dart';

class AIBibleService {
  static const String _apiKey = ''; // Replace with actual key
  late final GenerativeModel _model;
  
  AIBibleService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getVerseInsight(Verse verse) async {
    try {
      final prompt = '''
Analyze this specific Bible verse in detail:

"${verse.text}" (${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber})

Provide:
1. Historical Context: What was happening when this was written?
2. Theological Meaning: What does this teach about God, faith, or salvation?
3. Original Language: Key Greek/Hebrew words and their significance
4. Modern Application: How does this apply to life today?
5. Cross References: Related verses that support or expand this truth

Be specific to this exact verse and reference. Avoid generic responses.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final result = response.text?.trim();
      
      if (result != null && result.isNotEmpty && result.length > 50) {
        return result;
      }
      
      return 'AI analysis temporarily unavailable. Please try again.';
    } catch (e) {
      print('AI Error: $e');
      return 'AI service error. Please check your connection and try again.';
    }
  }

  Future<String> getThematicStudy(String theme, List<Verse> verses) async {
    try {
      final verseTexts = verses.map((v) => 
        '"${v.text}" (${v.bookName} ${v.chapterNumber}:${v.verseNumber})'
      ).join('\n');

      final prompt = '''
      Create a comprehensive thematic Bible study on "$theme" using these verses:
      
      $verseTexts
      
      Structure your response with:
      1. Introduction to the theme
      2. Key insights from each verse
      3. How they connect together
      4. Practical applications
      5. Questions for reflection
      6. Prayer points
      
      Make it inspiring and transformative.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate thematic study at this time.';
    } catch (e) {
      return _getMockThematicStudy(theme);
    }
  }

  Future<List<String>> getStudyQuestions(Verse verse) async {
    try {
      final prompt = '''
Create 5 specific study questions for this Bible verse:

"${verse.text}" (${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber})

Questions should be:
- Specific to this verse content
- Encourage deep reflection
- Mix understanding, application, and personal growth
- Avoid generic questions

Format as numbered list (1. 2. 3. etc.)''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      
      if (text.isNotEmpty) {
        final questions = text.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((q) => q.isNotEmpty)
            .toList();
            
        if (questions.isNotEmpty) {
          return questions;
        }
      }
      
      return ['AI questions temporarily unavailable. Please try again.'];
    } catch (e) {
      print('AI Error: $e');
      return ['AI service error. Please check your connection.'];
    }
  }

  Future<String> getPersonalizedDevotional(Verse verse, String userContext) async {
    try {
      final prompt = '''
      Create a personalized devotional based on this verse and the user's context:
      
      Verse: "${verse.text}" - ${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}
      User Context: $userContext
      
      Include:
      1. A warm, personal opening
      2. Connection between the verse and their situation
      3. Encouraging message
      4. Practical steps they can take
      5. A closing prayer
      
      Make it feel like a personal letter from a caring mentor.
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate devotional at this time.';
    } catch (e) {
      return _getMockDevotional(verse);
    }
  }

  Future<List<Map<String, String>>> getWordAnalysis(Verse verse) async {
    try {
      final prompt = '''
Analyze significant Greek/Hebrew words in this Bible verse:
"${verse.text}" (${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber})

For 2-3 key words in this verse, provide:
- English word from the verse
- Original Greek/Hebrew word
- Detailed analysis of meaning, usage, and significance

Return ONLY valid JSON array format:
[{"word": "english_word", "original": "greek/hebrew_word", "analysis": "detailed_explanation"}]

Focus only on words actually present in this specific verse.''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      
      if (text.isNotEmpty) {
        try {
          // Clean up the response to extract JSON
          final jsonStart = text.indexOf('[');
          final jsonEnd = text.lastIndexOf(']') + 1;
          
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonText = text.substring(jsonStart, jsonEnd);
            final List<dynamic> jsonList = jsonDecode(jsonText);
            
            final result = jsonList.map((item) => {
              'word': item['word']?.toString() ?? '',
              'original': item['original']?.toString() ?? '',
              'analysis': item['analysis']?.toString() ?? '',
            }).where((item) => item['word']!.isNotEmpty).toList();
            
            if (result.isNotEmpty) {
              return result;
            }
          }
        } catch (e) {
          print('JSON Parse Error: $e');
        }
      }
      
      return [{
        'word': 'Analysis Error',
        'original': 'N/A',
        'analysis': 'Word analysis temporarily unavailable. Please try again.'
      }];
    } catch (e) {
      print('AI Error: $e');
      return [{
        'word': 'Service Error',
        'original': 'N/A', 
        'analysis': 'AI service error. Please check your connection.'
      }];
    }
  }

  // Mock responses for when AI service is unavailable
  String _getMockInsight(Verse verse) {
    return '''
    **Historical Context**
    This verse comes from a pivotal moment in biblical history, reflecting the cultural and spiritual climate of its time.

    **Theological Significance**
    The passage reveals profound truths about God's character and His relationship with humanity.

    **Modern Application**
    In today's world, this verse speaks to our need for faith, hope, and perseverance in challenging times.

    **Cross References**
    Consider studying alongside similar passages that echo these themes throughout Scripture.
    ''';
  }

  String _getMockThematicStudy(String theme) {
    return '''
    # Thematic Study: $theme

    ## Introduction
    This theme runs throughout Scripture, revealing God's heart and plan for His people.

    ## Key Insights
    Each verse contributes unique perspectives to our understanding of this important topic.

    ## Practical Applications
    - Apply these truths in daily life
    - Share insights with others
    - Meditate on the deeper meanings

    ## Reflection Questions
    1. How does this theme impact your faith journey?
    2. What practical steps can you take?
    3. How can you share these insights?
    ''';
  }

  List<String> _getMockStudyQuestions(Verse verse) {
    return [
      'What is the main message of this verse?',
      'How does this apply to your current life situation?',
      'What does this reveal about God\'s character?',
      'How can you live out this truth practically?',
      'What questions does this verse raise for you?',
    ];
  }

  String _getMockDevotional(Verse verse) {
    return '''
    Dear Friend,

    Today's verse speaks directly to where you are in life. God's timing is perfect, and His word comes to encourage and guide you.

    The truth in this passage reminds us that we are never alone in our journey. Whatever challenges you're facing, God's love and wisdom are available to you.

    **Today's Action Step:**
    Take a moment to reflect on how this verse applies to your current situation.

    **Prayer:**
    Lord, thank You for Your word that speaks to my heart today. Help me to trust in Your goodness and walk in Your truth. Amen.
    ''';
  }

  List<Map<String, String>> _getMockWordAnalysisList(Verse verse) {
    return [
      {
        'word': 'love',
        'original': 'agape (Greek)',
        'analysis': 'Unconditional, sacrificial love. Different from eros (romantic) or philos (friendship). Represents God\'s divine nature and character.'
      },
      {
        'word': 'faith',
        'original': 'pistis (Greek)',
        'analysis': 'Trust and belief combined into active confidence, not passive acceptance. Implies covenant relationship and ongoing commitment.'
      },
    ];
  }
}