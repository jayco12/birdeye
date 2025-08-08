import 'package:get/get.dart';
import '../data/datasources/ai_bible_service.dart';
import '../domain/entities/verse.dart';

class AIController extends GetxController {
  final AIBibleService _aiService = AIBibleService();
  
  // Observable states
  final RxBool isGeneratingInsight = false.obs;
  final RxBool isGeneratingQuestions = false.obs;
  final RxBool isGeneratingDevotional = false.obs;
  final RxBool isGeneratingThematicStudy = false.obs;
  final RxBool isGeneratingWordAnalysis = false.obs;
  
  final RxString currentInsight = ''.obs;
  final RxList<String> currentQuestions = <String>[].obs;
  final RxString currentDevotional = ''.obs;
  final RxString currentThematicStudy = ''.obs;
  final RxList<Map<String, String>> currentWordAnalysis = <Map<String, String>>[].obs;
  
  final RxString error = ''.obs;
  
  // Cache for insights to avoid repeated API calls
  final Map<String, String> _insightCache = {};
  final Map<String, List<String>> _questionsCache = {};
  final Map<String, String> _devotionalCache = {};

  Future<void> generateVerseInsight(Verse verse) async {
    final cacheKey = '${verse.bookName}_${verse.chapterNumber}_${verse.verseNumber}';
    
    if (_insightCache.containsKey(cacheKey)) {
      currentInsight.value = _insightCache[cacheKey]!;
      return;
    }
    
    try {
      isGeneratingInsight.value = true;
      error.value = '';
      
      final insight = await _aiService.getVerseInsight(verse);
      currentInsight.value = insight;
      _insightCache[cacheKey] = insight;
      
    } catch (e) {
      error.value = 'Failed to generate insight: ${e.toString()}';
    } finally {
      isGeneratingInsight.value = false;
    }
  }

  Future<void> generateStudyQuestions(Verse verse) async {
    final cacheKey = '${verse.bookName}_${verse.chapterNumber}_${verse.verseNumber}';
    
    if (_questionsCache.containsKey(cacheKey)) {
      currentQuestions.value = _questionsCache[cacheKey]!;
      return;
    }
    
    try {
      isGeneratingQuestions.value = true;
      error.value = '';
      
      final questions = await _aiService.getStudyQuestions(verse);
      currentQuestions.value = questions;
      _questionsCache[cacheKey] = questions;
      
    } catch (e) {
      error.value = 'Failed to generate questions: ${e.toString()}';
    } finally {
      isGeneratingQuestions.value = false;
    }
  }

  Future<void> generatePersonalizedDevotional(Verse verse, {String userContext = ''}) async {
    final cacheKey = '${verse.bookName}_${verse.chapterNumber}_${verse.verseNumber}_$userContext';
    
    if (_devotionalCache.containsKey(cacheKey)) {
      currentDevotional.value = _devotionalCache[cacheKey]!;
      return;
    }
    
    try {
      isGeneratingDevotional.value = true;
      error.value = '';
      
      final devotional = await _aiService.getPersonalizedDevotional(verse, userContext);
      currentDevotional.value = devotional;
      _devotionalCache[cacheKey] = devotional;
      
    } catch (e) {
      error.value = 'Failed to generate devotional: ${e.toString()}';
    } finally {
      isGeneratingDevotional.value = false;
    }
  }

  Future<void> generateThematicStudy(String theme, List<Verse> verses) async {
    try {
      isGeneratingThematicStudy.value = true;
      error.value = '';
      
      final study = await _aiService.getThematicStudy(theme, verses);
      currentThematicStudy.value = study;
      
    } catch (e) {
      error.value = 'Failed to generate thematic study: ${e.toString()}';
    } finally {
      isGeneratingThematicStudy.value = false;
    }
  }

  Future<void> generateWordAnalysis(Verse verse) async {
    try {
      isGeneratingWordAnalysis.value = true;
      error.value = '';
      
      final analysis = await _aiService.getWordAnalysis(verse);
      currentWordAnalysis.assignAll(analysis);
      
    } catch (e) {
      error.value = 'Failed to generate word analysis: ${e.toString()}';
    } finally {
      isGeneratingWordAnalysis.value = false;
    }
  }

  void clearCurrentInsight() {
    currentInsight.value = '';
  }

  void clearCurrentQuestions() {
    currentQuestions.clear();
  }

  void clearCurrentDevotional() {
    currentDevotional.value = '';
  }

  void clearCurrentThematicStudy() {
    currentThematicStudy.value = '';
  }

  void clearCurrentWordAnalysis() {
    currentWordAnalysis.clear();
  }

  void clearError() {
    error.value = '';
  }

  // Get AI suggestions for verse exploration
  List<String> getVerseSuggestions(Verse verse) {
    return [
      '🧠 Get AI Insight',
      '❓ Study Questions',
      '📖 Personal Devotional',
      '🔍 Word Analysis',
      '📚 Cross References',
      '🎯 Life Application',
    ];
  }

  // Get theme suggestions for thematic studies
  List<String> getThemeSuggestions() {
    return [
      'Faith and Trust',
      'Love and Compassion',
      'Hope and Perseverance',
      'Wisdom and Understanding',
      'Prayer and Worship',
      'Forgiveness and Grace',
      'Leadership and Service',
      'Peace and Joy',
      'Strength in Trials',
      'God\'s Promises',
    ];
  }
}