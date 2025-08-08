import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../application/notes_controller.dart';
import '../../domain/entities/highlight.dart';

class HighlightedVerseText extends StatelessWidget {
  final String text;
  final String verseReference;
  final TextStyle? baseStyle;

  const HighlightedVerseText({
    super.key,
    required this.text,
    required this.verseReference,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final notesController = Get.find<NotesController>();
    
    return Obx(() {
      final highlights = notesController.getHighlightsForVerse(verseReference);
      
      if (highlights.isEmpty) {
        return SelectableText(
          text,
          style: baseStyle,
          onSelectionChanged: (selection, cause) {
            if (selection.isValid && selection.textInside(text).isNotEmpty) {
              _showHighlightOptions(context, selection, verseReference);
            }
          },
        );
      }

      return SelectableText.rich(
        _buildHighlightedTextSpan(text, highlights),
        style: baseStyle,
        onSelectionChanged: (selection, cause) {
          if (selection.isValid && selection.textInside(text).isNotEmpty) {
            _showHighlightOptions(context, selection, verseReference);
          }
        },
      );
    });
  }

  TextSpan _buildHighlightedTextSpan(String text, List<Highlight> highlights) {
    if (highlights.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Sort highlights by start index
    highlights.sort((a, b) => a.startIndex.compareTo(b.startIndex));

    for (var highlight in highlights) {
      // Add text before highlight
      if (currentIndex < highlight.startIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, highlight.startIndex),
          style: baseStyle,
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(highlight.startIndex, highlight.endIndex),
        style: baseStyle?.copyWith(
          backgroundColor: _getHighlightColor(highlight.color),
        ),
      ));

      currentIndex = highlight.endIndex;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  Color _getHighlightColor(HighlightColor color) {
    switch (color) {
      case HighlightColor.yellow:
        return Colors.yellow.withOpacity(0.3);
      case HighlightColor.green:
        return Colors.green.withOpacity(0.3);
      case HighlightColor.blue:
        return Colors.blue.withOpacity(0.3);
      case HighlightColor.pink:
        return Colors.pink.withOpacity(0.3);
      case HighlightColor.orange:
        return Colors.orange.withOpacity(0.3);
    }
  }

  void _showHighlightOptions(BuildContext context, TextSelection selection, String verseReference) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Highlight: "${selection.textInside(text)}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: HighlightColor.values.map((color) {
                return GestureDetector(
                  onTap: () {
                    final notesController = Get.find<NotesController>();
                    notesController.addHighlight(
                      verseReference,
                      selection.start,
                      selection.end,
                      color,
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getHighlightColor(color),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.format_color_fill, color: Colors.black54),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}