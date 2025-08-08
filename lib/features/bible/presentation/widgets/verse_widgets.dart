import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';

typedef VerseTapCallback = void Function(Verse verse);

class VerseWidget extends StatelessWidget {
  final Verse verse;
  final bool isHighlighted;
  final VerseTapCallback? onTap;

  const VerseWidget({
    super.key,
    required this.verse,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighlighted ? Colors.yellow.withOpacity(0.3) : Colors.transparent;

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap!(verse);
      },
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${verse.verseNumber}. ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: verse.text,
              ),
            ],
          ),
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
