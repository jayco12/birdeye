import 'package:get/get.dart';
import '../data/datasources/scholarly_analysis_service.dart';
import '../domain/entities/verse.dart';

class ScholarlyController extends GetxController {
  final ScholarlyAnalysisService _analysisService = ScholarlyAnalysisService();
  
  final RxBool isLoadingAnalysis = false.obs;
  final RxBool isLoadingQuestions = false.obs;
  final RxString currentAnalysis = ''.obs;
  final RxList<String> currentQuestions = <String>[].obs;
  final RxString studyUrl = ''.obs;
  final RxString error = ''.obs;

  Future<void> loadVerseAnalysis(Verse verse) async {
    try {
      isLoadingAnalysis.value = true;
      error.value = '';
      
      final result = await _analysisService.getVerseAnalysis(verse);
      
      if (result.containsKey('error')) {
        error.value = result['error'];
        studyUrl.value = result['url'] ?? '';
        return;
      }
      
      currentAnalysis.value = result['analysis'] ?? '';
      currentQuestions.value = List<String>.from(result['questions'] ?? []);
      studyUrl.value = result['url'] ?? '';
      
    } catch (e) {
      error.value = 'Failed to load analysis: $e';
    } finally {
      isLoadingAnalysis.value = false;
    }
  }

  Future<void> loadStudyQuestions(Verse verse) async {
    try {
      isLoadingQuestions.value = true;
      error.value = '';
      
      final questions = await _analysisService.getStudyQuestions(verse);
      currentQuestions.value = questions;
      
    } catch (e) {
      error.value = 'Failed to load study questions: $e';
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  void clearAnalysis() {
    currentAnalysis.value = '';
    studyUrl.value = '';
  }

  void clearQuestions() {
    currentQuestions.clear();
  }

  void clearAll() {
    clearAnalysis();
    clearQuestions();
    error.value = '';
  }
}