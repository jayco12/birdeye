import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../application/bible_controller.dart';
import '../../domain/entities/bible_book.dart';
import '../../domain/entities/verse.dart';
import '../widgets/verse_widgets.dart';
import 'other_screens.dart';

class BibleScreen extends GetView<BibleController> {
  BibleScreen({super.key});

  final TextEditingController verseInputController = TextEditingController();

  void _showVerseDetails(BuildContext context, Verse verse) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Verse ${verse.verseNumber} Explanation'),
        content: Text(
          'Placeholder theological insights or commentary:\n\n"${verse.text}"',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Reader')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar for direct verse input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: verseInputController,
                    decoration: const InputDecoration(
                      labelText: 'Enter verse (e.g. John 3:16)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
  onPressed: () {
    final input = verseInputController.text.trim();
    if (input.isNotEmpty) {
      controller.searchVerses(input);
    }
  },
  child: const Text('Search'),
),

              ],
            ),

            const SizedBox(height: 12),

            // Book picker dropdown
            Obx(() {
              final books = controller.books;
              final selectedBook = controller.selectedBook.value;
              return DropdownButton<BibleBook>(
                value: selectedBook,
                isExpanded: true,
                onChanged: (newBook) {
                  if (newBook != null) {
                    controller.selectBook(newBook);
                  }
                },
                items: books.map((book) {
                  return DropdownMenuItem(value: book, child: Text(book.name));
                }).toList(),
              );
            }),

            const SizedBox(height: 10),

            // Chapter picker (horizontal scroll)
            Obx(() {
              final chapters = controller.chapters;
              final selectedChapter = controller.selectedChapter.value;
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: chapters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final chapter = chapters[index];
                    final isSelected = selectedChapter?.chapterNumber == chapter.chapterNumber;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        controller.selectChapter(chapter);
                      },
                      child: Text('${chapter.chapterNumber}'),
                    );
                  },
                ),
              );
            }),
Obx(() {
  final current = controller.selectedTranslation.value;
  return DropdownButton<String>(
    value: current,
    onChanged: (value) {
      if (value != null) {
        controller.setTranslation(value);
      }
    },
    items: ['KJV', 'NIV', 'ESV', 'NASB']
        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
        .toList(),
  );
}),

            const SizedBox(height: 20),

            // Verses list area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.error.value.isNotEmpty) {
                  return Center(child: Text(controller.error.value, style: const TextStyle(color: Colors.red)));
                } else if (controller.verses.isEmpty) {
                  return const Center(child: Text('No verses found.'));
                }
                return ListView.builder(
  itemCount: controller.verses.length,
  itemBuilder: (context, index) {
    final verse = controller.verses[index];
    return ListTile(
      title: Text('${verse.verseNumber}. ${verse.text}'),
      onTap: () {
        _showVerseOptions(context, verse.reference);
      },
    );
  },
);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
void _showVerseOptions(BuildContext context, String reference) {
  final ref = reference.replaceAll(' ', '_').replaceAll(':', '-').toLowerCase(); // e.g., john_3-16

  showModalBottomSheet(
    context: context,
    builder: (ctx) => Wrap(
      children: [
        _buildOption(ctx, 'Interlinear', 'https://biblehub.com/interlinear/$ref.htm'),
        _buildOption(ctx, 'Lexicon', 'https://biblehub.com/lexicon/$ref.htm'),
        _buildOption(ctx, 'Commentary', 'https://biblehub.com/commentaries/$ref.htm'),
        _buildOption(ctx, 'Greek/Hebrew', 'https://biblehub.com/greek/$ref.htm'),
        _buildOption(ctx, 'Strong\'s', 'https://biblehub.com/str/$ref.htm'),
        _buildOption(ctx, 'Videos', 'https://biblehub.com/videos/$ref.htm'),
      ],
    ),
  );
}

Widget _buildOption(BuildContext ctx, String label, String url) {
  return ListTile(
    title: Text(label),
    onTap: () {
      Navigator.pop(ctx);
      Get.to(() => VerseWebViewScreen(title: label, url: url));
    },
  );
}
