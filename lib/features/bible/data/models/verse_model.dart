
import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  VerseModel({
    required String bookAbbreviation,
    required int chapterNumber,
    required super.reference,
    required int verseNumber,
    required String text,
    required String translation,
  }) : super(
          bookAbbreviation: bookAbbreviation,
          chapterNumber: chapterNumber,
          verseNumber: verseNumber,
          text: text,
          translation: translation,
        );

factory VerseModel.fromJson(Map<String, dynamic> json, String translation) {
  return VerseModel(
    bookAbbreviation: json['book']?.toString() ?? '',
    chapterNumber: json['chapter'] is int
        ? json['chapter'] as int
        : int.tryParse(json['chapter']?.toString() ?? '') ?? 0,
    reference: json['reference']?.toString() ?? '',
    verseNumber: json['verse'] is int
        ? json['verse'] as int
        : int.tryParse(json['verse']?.toString() ?? '') ?? 0,
    text: json['text']?.toString() ?? '',
    translation: translation,
  );
}
}