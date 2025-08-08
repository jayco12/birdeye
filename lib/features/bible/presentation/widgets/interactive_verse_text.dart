import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';
import '../../data/models/verse_model.dart';
import '../screens/strongs_detail_screen.dart';

class InteractiveVerseText extends StatelessWidget {
  final Verse verse;
  final TextStyle? baseStyle;

  const InteractiveVerseText({
    super.key,
    required this.verse,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (verse is VerseModel) {
      final verseModel = verse as VerseModel;
      if (verseModel.phraseData.isNotEmpty) {
        return Wrap(
          children: verseModel.phraseData.map((phrase) {
            final hasStrongs = phrase['hasStrongs'] as bool;
            final text = phrase['text'] as String;
            
            return GestureDetector(
              onTap: hasStrongs ? () => _onPhraseTap(context, phrase) : null,
              child: Text(
                text,
                style: baseStyle?.copyWith(
                  decoration: hasStrongs ? TextDecoration.underline : null,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: hasStrongs ? const Color(0xFF2196F3) : null,
                ),
              ),
            );
          }).toList(),
        );
      }
    }
    
    // Fallback for verses without phrase data
    return Text(verse.text, style: baseStyle);
  }

  void _onPhraseTap(BuildContext context, Map<String, dynamic> phrase) {
    final strongsNumber = phrase['strongsNumber'] as String?;
    final definition = phrase['definition'] as String?;
    final originalWord = phrase['originalWord'] as String?;
    final text = phrase['text'] as String;
    
    if (strongsNumber != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StrongsDetailScreen(
            word: text,
            strongsNumber: strongsNumber,
            verse: verse,
            position: 0,
          ),
        ),
      );
    }
  }

  bool _isOldTestament(String bookName) {
    const otBooks = [
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
      'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
      '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
      'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
      'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah',
      'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
      'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
      'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
    ];
    return otBooks.contains(bookName);
  }
}