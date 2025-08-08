import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../../../core/global_widgets/loading_states.dart';
import '../../application/bible_controller.dart';
import '../../application/ai_controller.dart';
import '../../domain/entities/verse.dart';
import 'bible_comparison_screen.dart';
import 'offline_manager_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'all_notes_screen.dart';
import '../../application/notes_controller.dart';
import '../../data/datasources/verse_of_day_service.dart';
import '../../data/models/verse_model.dart';
import '../widgets/verse_card_widget.dart';
import '../../../gamification/application/gamification_controller.dart';
import '../../../gamification/presentation/screens/theology_cards_screen.dart';
import '../../../apologetics/presentation/screens/apologetics_resources_screen.dart';

class BibleScreen extends GetView<BibleController> {
  BibleScreen({super.key});

  final TextEditingController verseInputController = TextEditingController();
  final AIController aiController = Get.put(AIController());
  final RxMap<String, dynamic> verseOfDay = <String, dynamic>{}.obs;



  @override
  Widget build(BuildContext context) {
    Get.put(NotesController());
    Get.put(GamificationController());
    
    // Load verse of the day and record study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVerseOfDay();
      Get.find<GamificationController>().recordStudySession();
    });
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildCompactTopSection(),
                  const SizedBox(height: 16),
                  _buildSelectionSection(),
                  const SizedBox(height: 16),
                  _buildVersesSection(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Blackbird Bible',
            style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
          ),

          centerTitle: true,
          background: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Icon(
                Icons.auto_stories,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.compare_arrows, color: Colors.white),
          onPressed: () => Get.to(() => const BibleComparisonScreen()),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'bookmarks',
              child: Row(
                children: [
                  Icon(Icons.bookmark, size: 20),
                  SizedBox(width: 8),
                  Text('Bookmarks'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'notes',
              child: Row(
                children: [
                  Icon(Icons.note, size: 20),
                  SizedBox(width: 8),
                  Text('All Notes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'offline',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Offline Manager'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'bookmarks':
                Get.to(() => const BookmarksScreen());
                break;
              case 'notes':
                Get.to(() => const AllNotesScreen());
                break;
              case 'offline':
                Get.to(() => const OfflineManagerScreen());
                break;
              case 'settings':
                Get.to(() => const SettingsScreen());
                break;
            }
          },
        ),
      ],
    );
  }



  Widget _buildSelectionSection() {
    return GlassCard(
      child: Obx(() => Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildCompactDropdown(
              value: controller.selectedBook.value,
              items: controller.books.map((book) => DropdownMenuItem(
                value: book,
                child: Text(book.name, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              )).toList(),
              onChanged: (newBook) {
                if (newBook != null) {
                  controller.selectBook(newBook);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildCompactDropdown(
              value: controller.selectedChapter.value,
              items: controller.chapters.map((chapter) => DropdownMenuItem(
                value: chapter,
                child: Text('${chapter.chapterNumber}', style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              )).toList(),
              onChanged: (newChapter) {
                if (newChapter != null) {
                  controller.selectChapter(newChapter);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildCompactDropdown(
              value: controller.selectedTranslation.value,
              items: ['NET', 'KJV', 'NIV', 'ESV', 'NASB']
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setTranslation(value);
                }
              },
            ),
          ),
        ],
      )),
    ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideX(begin: 0.1);
  }

  Widget _buildCompactDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        dropdownColor: AppColors.surface,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 12),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onChanged: onChanged,
        items: items,
      ),
    );
  }




  Widget _buildVersesSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      } else if (controller.error.value.isNotEmpty) {
        return _buildErrorState();
      } else if (controller.verses.isEmpty) {
        return _buildEmptyState();
      }
      return GestureDetector(
        onPanUpdate: (details) {
          // Detect horizontal swipe
          if (details.delta.dx > 10) {
            _navigateToPreviousChapter();
          } else if (details.delta.dx < -10) {
            _navigateToNextChapter();
          }
        },
        child: _buildVersesList(),
      );
    });
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: const VerseSkeletonLoader()
              .animate(delay: (index * 100).ms)
              .fadeIn(duration: 600.ms),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ErrorStateWidget(
      title: 'Error loading verses',
      message: controller.error.value,
      onRetry: () {
        if (controller.selectedBook.value != null && 
            controller.selectedChapter.value != null) {
          controller.loadVerses(
            controller.selectedBook.value!.abbreviation,
            controller.selectedChapter.value!.chapterNumber,
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'No verses found',
      message: 'Try selecting a different book or chapter',
      icon: Icons.search_off,
      onAction: () {
        // Reset to first book and chapter
        if (controller.books.isNotEmpty) {
          controller.selectBook(controller.books.first);
        }
      },
      actionText: 'Reset Selection',
    );
  }

  Widget _buildVersesList() {
    return Builder(
      builder: (context) => AnimationLimiter(
        child: Column(
          children: controller.verses.asMap().entries.map((entry) {
            final index = entry.key;
            final verse = entry.value;
            
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildVerseCard(verse, index, context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVerseCard(Verse verse, int index, BuildContext context) {
    return VerseCardWidget(
      verse: verse,
      showBookReference: true,
    );
  }



  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionBubble(
          icon: Icons.school,
          backgroundColor: AppColors.accent,
          onPressed: () => _showLearningMenu(),
        ),
        const SizedBox(height: 8),
        FloatingActionBubble(
          icon: Icons.search,
          onPressed: () => _focusSearchField(),
        ),
      ],
    );
  }

  void _showLearningMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Learning Features',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLearningMenuItem(
              icon: Icons.psychology,
              title: 'Theology Game',
              subtitle: 'Test your theological knowledge',
              gradient: AppColors.primaryGradient,
              onTap: () {
                Get.back();
                Get.to(() => const TheologyCardsScreen());
              },
            ),
            const SizedBox(height: 12),
            _buildLearningMenuItem(
              icon: Icons.shield,
              title: 'Apologetics Resources',
              subtitle: 'Defend your faith with knowledge',
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.tertiary],
              ),
              onTap: () {
                Get.back();
                Get.to(() => const ApologeticsResourcesScreen());
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: gradient.colors.first.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradient.colors.first.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: gradient.colors.first,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  void _focusSearchField() {
    // Focus on search field and scroll to top
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }



  Widget _buildCompactTopSection() {
    return GlassCard(
      child: Column(
        children: [
          // Compact Progress Header
          Obx(() {
            final controller = Get.find<GamificationController>();
            final progress = controller.userProgress.value;
            return Row(
              children: [
                // Compact streak
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${progress.currentStreak}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Compact levels
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Discipline:${progress.disciplineLevel} Theology:${progress.theologicalDepth}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Compact points
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: AppColors.accent, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${progress.totalPoints}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          // Search Section
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: verseInputController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search verse (e.g. John 3:16)',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final input = verseInputController.text.trim();
                      if (input.isNotEmpty) {
                        controller.searchVerses(input);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Verse of Day (if available)
          Obx(() {
            if (verseOfDay.isEmpty) return const SizedBox.shrink();
            final verse = verseOfDay['verse'] as VerseModel;
            final insight = verseOfDay['insight'] as String;
            return GestureDetector(
              onTap: () => _showVerseOfDayDialog(verse, insight),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_stories, color: AppColors.accent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${verse.reference}: ${verse.text}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.touch_app, color: AppColors.accent, size: 12),
                  ],
                ),
              ),
            );
          }),
          // Learning Features - Always visible and prominent
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Learning Features',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.to(() => const TheologyCardsScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.psychology, color: Colors.white, size: 20),
                                const SizedBox(height: 2),
                                Text(
                                  'Theology Game',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.secondary, AppColors.tertiary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.to(() => const ApologeticsResourcesScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shield, color: Colors.white, size: 20),
                                const SizedBox(height: 2),
                                Text(
                                  'Apologetics',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  void _loadVerseOfDay() async {
    try {
      final data = await VerseOfDayService.getVerseOfDay();
      if (data.isNotEmpty) {
        verseOfDay.value = data;
      }
    } catch (e) {
      print('Error loading verse of day: $e');
    }
  }

  void _showVerseOfDayDialog(VerseModel verse, String insight) {
    Get.dialog(
      AlertDialog(
        title: Text(
          verse.reference,
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
        ),
        content: Text(
          verse.text,
          style: AppTextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _navigateToNextChapter() {
    final currentChapter = controller.selectedChapter.value;
    if (currentChapter == null) return;
    
    final chapters = controller.chapters;
    final currentIndex = chapters.indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);
    
    if (currentIndex < chapters.length - 1) {
      controller.selectChapter(chapters[currentIndex + 1]);
    }
  }

  void _navigateToPreviousChapter() {
    final currentChapter = controller.selectedChapter.value;
    if (currentChapter == null) return;
    
    final chapters = controller.chapters;
    final currentIndex = chapters.indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);
    
    if (currentIndex > 0) {
      controller.selectChapter(chapters[currentIndex - 1]);
    }
  }
  } 

String formatReference(String reference) {
  reference = reference.trim();
  print('📖 Raw incoming reference: $reference');

  // Normalize spacing and remove trailing translation names or labels
  reference = reference.replaceAll(RegExp(r'\s+'), ' '); // Fix spacing
  reference = reference.replaceAll(RegExp(r'([a-zA-Z])\.'), r'\1'); // remove periods like "Jn." → "Jn"
  reference = reference.replaceAll(RegExp(r'(KJV|NIV|ESV|NASB|MSG)$'), '').trim(); // strip trailing translation

  final regex = RegExp(r'^([\d]*\s?[A-Za-z]+)\s+(\d+):(\d+)$');
  final match = regex.firstMatch(reference);

  if (match != null) {
    String book = match.group(1)!.toLowerCase().replaceAll(' ', '');
    String chapter = match.group(2)!;
    String verse = match.group(3)!;
    final result = '$book/$chapter-$verse';
    print('✅ Formatted reference to: $result');
    return result;
  }

  print('❌ No match for reference format');
  return '';
}
