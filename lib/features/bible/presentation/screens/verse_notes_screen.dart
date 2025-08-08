import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../application/notes_controller.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/highlight.dart';
import '../widgets/highlighted_verse_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class VerseNotesScreen extends StatelessWidget {
  final Verse verse;

  const VerseNotesScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final notesController = Get.put(NotesController());
    final noteController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: FlexibleSpaceBar(
                  title: Text(
                    '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
              actions: [
                FloatingActionBubble(
                  icon: Icons.share,
                  onPressed: () => notesController.exportToNativeNotes(verse),
                ).animate().scale(duration: 300.ms),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildVerseCard().animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),
                    _buildNoteInput(noteController, notesController).animate().fadeIn(duration: 700.ms, delay: 100.ms),
                    const SizedBox(height: 16),
                    _buildNotesAndHighlights(notesController).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} (${verse.translation})',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          HighlightedVerseText(
            text: verse.text,
            verseReference: verse.reference,
            baseStyle: AppTextStyles.bodyLarge.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(TextEditingController noteController, NotesController notesController) {
    return CompactGlassCard(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionBubble(
            icon: Icons.add,
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                notesController.addNote(verse.reference, noteController.text);
                noteController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesAndHighlights(NotesController notesController) {
    return Obx(() {
      final notes = notesController.getNotesForVerse(verse.reference);
      final highlights = notesController.getHighlightsForVerse(verse.reference);

      if (notes.isEmpty && highlights.isEmpty) {
        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.note_add, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notes or highlights yet\nSelect text to highlight or add notes below',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlights.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.warningGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.highlight, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Highlights',
                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...highlights.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildHighlightItem(entry.value, notesController)
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: 0.3);
            }),
            const SizedBox(height: 16),
          ],
          if (notes.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.infoGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.note, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...notes.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildNoteItem(entry.value, notesController)
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: 0.3);
            }),
          ],
        ],
      );
    });
  }

  Widget _buildNoteItem(VerseNote note, NotesController controller) {
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.infoGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.note, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(note.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FloatingActionBubble(
            icon: Icons.delete,
            onPressed: () => controller.deleteNote(note.id, verse.reference),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(Highlight highlight, NotesController controller) {
    final highlightedText = verse.text.substring(highlight.startIndex, highlight.endIndex);
    
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getHighlightColor(highlight.color),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.format_color_fill, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$highlightedText"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(highlight.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FloatingActionBubble(
            icon: Icons.delete,
            onPressed: () => controller.deleteHighlight(highlight.id, verse.reference),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}