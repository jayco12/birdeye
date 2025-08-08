class ScriptureDataModel {
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String insights;
  final List<String> studyQuestions;
  final List<WordAnalysis> wordAnalysis;
  final DateTime generatedAt;

  ScriptureDataModel({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.insights,
    required this.studyQuestions,
    required this.wordAnalysis,
    required this.generatedAt,
  });

  factory ScriptureDataModel.fromJson(Map<String, dynamic> json) {
    return ScriptureDataModel(
      book: json['book'],
      chapter: json['chapter'],
      verse: json['verse'],
      text: json['text'],
      insights: json['insights'],
      studyQuestions: (json['study_questions'] as List).cast<String>(),
      wordAnalysis: (json['word_analysis'] as List).map((w) => WordAnalysis.fromJson(w)).toList(),
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'insights': insights,
      'study_questions': studyQuestions,
      'word_analysis': wordAnalysis.map((w) => w.toJson()).toList(),
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  String get reference => '$book $chapter:$verse';
}

class WordAnalysis {
  final String word;
  final String original;
  final String analysis;

  WordAnalysis({
    required this.word,
    required this.original,
    required this.analysis,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) {
    return WordAnalysis(
      word: json['word'],
      original: json['original'],
      analysis: json['analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'original': original,
      'analysis': analysis,
    };
  }
}