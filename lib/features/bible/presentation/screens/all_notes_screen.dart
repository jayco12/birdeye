import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../application/notes_controller.dart';
import '../../domain/entities/highlight.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class AllNotesScreen extends GetView<NotesController> {
  const AllNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Notes & Highlights',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final allNotes = <MapEntry<String, dynamic>>[];
                  
                  // Combine notes and highlights
                  controller.verseNotes.forEach((reference, notes) {
                    for (var note in notes) {
                      allNotes.add(MapEntry(reference, note));
                    }
                  });
                  
                  controller.verseHighlights.forEach((reference, highlights) {
                    for (var highlight in highlights) {
                      allNotes.add(MapEntry(reference, highlight));
                    }
                  });
                  
                  // Sort by creation date
                  allNotes.sort((a, b) {
                    final aDate = a.value is VerseNote 
                        ? (a.value as VerseNote).createdAt 
                        : (a.value as Highlight).createdAt;
                    final bDate = b.value is VerseNote 
                        ? (b.value as VerseNote).createdAt 
                        : (b.value as Highlight).createdAt;
                    return bDate.compareTo(aDate);
                  });

                  if (allNotes.isEmpty) {
                    return _buildEmptyState().animate().fadeIn(duration: 800.ms).scale();
                  }

                  return Column(
                    children: allNotes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final noteEntry = entry.value;
                      final reference = noteEntry.key;
                      final item = noteEntry.value;

                      Widget card;
                      if (item is VerseNote) {
                        card = _buildNoteCard(reference, item);
                      } else if (item is Highlight) {
                        card = _buildHighlightCard(reference, item);
                      } else {
                        card = const SizedBox.shrink();
                      }

                      return card
                          .animate(delay: (index * 100).ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.3);
                    }).toList(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.note_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notes or highlights yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding notes and highlights\nto your favorite verses',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String reference, VerseNote note) {
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reference,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              FloatingActionBubble(
                icon: Icons.delete,
                onPressed: () => controller.deleteNote(note.id, reference),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDate(note.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String reference, Highlight highlight) {
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  reference,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              FloatingActionBubble(
                icon: Icons.delete,
                onPressed: () => controller.deleteHighlight(highlight.id, reference),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getHighlightColor(highlight.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getHighlightColor(highlight.color).withOpacity(0.5)),
            ),
            child: Text(
              '${highlight.color.name.toUpperCase()} HIGHLIGHT',
              style: AppTextStyles.bodySmall.copyWith(
                color: _getHighlightColor(highlight.color),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDate(highlight.createdAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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