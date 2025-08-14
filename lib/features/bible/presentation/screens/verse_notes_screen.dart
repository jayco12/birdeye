import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../application/notes_controller.dart';
import '../../data/models/contribution_model.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/highlight.dart'; // You might keep highlights too
import '../widgets/highlighted_verse_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

enum DisplayMode { notes, contributions }

class VerseNotesScreen extends StatelessWidget {
  final Verse verse;

  VerseNotesScreen({super.key, required this.verse});

final Rx<DisplayMode> displayMode = DisplayMode.notes.obs;

  final TextEditingController contributorController = TextEditingController();

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
                    _buildVerseCard(),
                    const SizedBox(height: 16),
                    Obx(() => ToggleButtons(
                      color: AppColors.textSecondary,
                      isSelected: [
                        displayMode.value == DisplayMode.notes,
                        displayMode.value == DisplayMode.contributions,
                      ],
                      onPressed: (index) {
                        displayMode.value = DisplayMode.values[index];
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Notes', style: TextStyle(color: AppColors.textPrimary),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Contributions', style: TextStyle(color: AppColors.textPrimary),),
                        ),
                      ],
                    )),
                    const SizedBox(height: 16),

                    // Contributor Name input - only show if contributions are selected
                    Obx(() {
                      if (displayMode.value == DisplayMode.contributions) {
                        return GlassCard(
                          child: TextField(
                            controller: contributorController,
                            decoration: InputDecoration(
                              hintText: 'Contributor name',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 12),
                    if (displayMode.value == DisplayMode.contributions)
                      const SizedBox(height: 12),

                    _buildNoteInput(noteController, contributorController, notesController),
                    const SizedBox(height: 16),
                    Obx(() => _buildItemsList(notesController)),
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
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber} ("KJV")',
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
  Widget _buildNoteInput(TextEditingController noteController, TextEditingController contributorController, NotesController notesController) {
    return Obx(() {
      final mode = displayMode.value;
      return GlassCard(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: mode == DisplayMode.notes
                      ? 'Add a note...'
                      : 'Add a contribution...',
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
                final text = noteController.text.trim();
                if (text.isNotEmpty) {
                  if (mode == DisplayMode.notes) {
                    notesController.addNote(verse.reference, text);
                  } else {
                    final contributorName = contributorController.text.trim();
                    if (contributorName.isEmpty) {
                      Get.snackbar('Error', 'Please enter contributor name');
                      return;
                    }
                    notesController.addContribution(verse.reference, text, contributorName);
                    contributorController.clear();
                  }
                  noteController.clear();
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildItemsList(NotesController notesController) {
    final mode = displayMode.value;

    final allItems = <MapEntry<String, dynamic>>[];

    if (mode == DisplayMode.notes) {
      notesController.verseNotes[verse.reference]?.forEach((note) {
        allItems.add(MapEntry(verse.reference, note));
      });
    } else {
      notesController.verseContributions[verse.reference]?.forEach((contrib) {
        allItems.add(MapEntry(verse.reference, contrib));
      });
    }

    if (allItems.isEmpty) {
      return Center(
        child: Text(
          mode == DisplayMode.notes
              ? 'No notes yet. Add your notes!'
              : 'No contributions yet. Be the first to contribute!',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allItems.map((entry) {
        if (mode == DisplayMode.notes && entry.value is VerseNote) {
          final note = entry.value as VerseNote;
          return _buildNoteItem(note, notesController);
        } else if (mode == DisplayMode.contributions && entry.value is VerseContribution) {
          final contrib = entry.value as VerseContribution;
          return _buildContributionItem(contrib, notesController);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
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
            child: Text(
              note.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
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

  Widget _buildContributionItem(VerseContribution contribution, NotesController controller) {
    return CompactGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              contribution.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          FloatingActionBubble(
            icon: Icons.delete,
            onPressed: () => controller.deleteContribution(contribution.id, verse.reference),
          ),
        ],
      ),
    );
  }
}
