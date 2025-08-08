import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../application/bible_controller.dart';
import '../../application/ai_controller.dart';
import '../../domain/entities/bible_book.dart' hide Testament;
import '../../domain/entities/verse.dart';
import 'ai_verse_analysis_screen.dart';
import 'other_screens.dart';
import 'verse_tools_screen.dart';
import 'bible_comparison_screen.dart';
import 'offline_manager_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'verse_notes_screen.dart';
import 'all_notes_screen.dart';
import '../../application/notes_controller.dart';
import '../widgets/interactive_verse_text.dart';
import '../../data/datasources/verse_of_day_service.dart';
import '../widgets/verse_of_day_card.dart';
import '../../../gamification/application/gamification_controller.dart';
import '../../../gamification/presentation/widgets/progress_header.dart';
import '../../../gamification/presentation/screens/theology_cards_screen.dart';
import '../../../apologetics/presentation/screens/apologetics_resources_screen.dart';

class BibleScreen extends GetView<BibleController> {
  BibleScreen({super.key});

  final TextEditingController verseInputController = TextEditingController();
  final AIController aiController = Get.put(AIController());
  final RxMap<String, dynamic> verseOfDay = <String, dynamic>{}.obs;

  void _showAIVerseAnalysis(BuildContext context, Verse verse) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            AIVerseAnalysisScreen(verse: verse),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

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
                  const ProgressHeader(),
                  const SizedBox(height: 20),
                  _buildSearchSection(),
                  const SizedBox(height: 20),
                  _buildVerseOfDaySection(),
                  const SizedBox(height: 20),
                  _buildLearningSection(),
                  const SizedBox(height: 20),
                  _buildSelectionSection(),
                  const SizedBox(height: 20),
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

  Widget _buildSearchSection() {
    return CompactGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Scripture',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: verseInputController,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Enter verse (e.g. John 3:16)',
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedGradientButton(
                text: 'Search',
                icon: Icons.search,
                onPressed: () {
                  final input = verseInputController.text.trim();
                  if (input.isNotEmpty) {
                    controller.searchVerses(input);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2);
  }

  Widget _buildSelectionSection() {
    return Column(
      children: [
        _buildBookAndTranslationSelector(),
        const SizedBox(height: 16),
        _buildChapterSelector(),
      ],
    );
  }

  Widget _buildBookAndTranslationSelector() {
    return CompactGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Book & Translation',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Obx(() {
                  final books = controller.books;
                  final selectedBook = controller.selectedBook.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: DropdownButton<BibleBook>(
                      value: selectedBook,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: AppTextStyles.bodyLarge,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onChanged: (newBook) {
                        if (newBook != null) {
                          controller.selectBook(newBook);
                        }
                      },
                      items: books.map((book) {
                        return DropdownMenuItem(
                          value: book,
                          child: Text(book.name),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final current = controller.selectedTranslation.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: DropdownButton<String>(
                      value: current,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: AppTextStyles.bodyLarge,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setTranslation(value);
                        }
                      },
                      items: ['NET', 'KJV', 'NIV', 'ESV', 'NASB']
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 800.ms).slideX(begin: 0.2);
  }

  Widget _buildChapterSelector() {
    return CompactGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Chapter',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final chapters = controller.chapters;
            final selectedChapter = controller.selectedChapter.value;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: DropdownButton<dynamic>(
                value: selectedChapter,
                isExpanded: true,
                underline: const SizedBox(),
                style: AppTextStyles.bodyLarge,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onChanged: (newChapter) {
                  if (newChapter != null) {
                    controller.selectChapter(newChapter);
                  }
                },
                items: chapters.map((chapter) {
                  return DropdownMenuItem(
                    value: chapter,
                    child: Text('Chapter ${chapter.chapterNumber}'),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 800.ms).slideX(begin: -0.2);
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
      return _buildVersesList();
    });
  }

  Widget _buildLoadingState() {
    return GlassCard(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading verses...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildErrorState() {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading verses',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }

  Widget _buildEmptyState() {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No verses found',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different book or chapter',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${verse.verseNumber}',
                    style: AppTextStyles.verseNumber.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                  style: AppTextStyles.verseReference,
                ),
              ),
              FloatingActionBubble(
                icon: Icons.psychology,
                onPressed: () => _showAIVerseAnalysis(context, verse),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InteractiveVerseText(
            verse: verse,
            baseStyle: AppTextStyles.verseText,
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.note_add,
                label: 'Notes',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerseNotesScreen(verse: verse),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => _buildActionButton(
                icon: controller.isBookmarked(verse) 
                    ? Icons.bookmark 
                    : Icons.bookmark_border,
                label: 'Bookmark',
                isActive: controller.isBookmarked(verse),
                onPressed: () => controller.toggleBookmark(verse),
              )),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.build,
                label: 'Tools',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerseToolsScreen(verse: verse),
                  ),
                ),
              ),
              const Spacer(),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () => _shareVerse(verse),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
              ? AppColors.primary 
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      
        FloatingActionBubble(
          icon: Icons.search,
          onPressed: () => _focusSearchField(),
        ),
      ],
    );
  }

  void _shareVerse(Verse verse) {
    // Implement verse sharing functionality
    Get.snackbar(
      'Share Verse',
      'Sharing functionality will be implemented soon!',
      backgroundColor: AppColors.info.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }


  void _focusSearchField() {
    // Focus on search field and scroll to top
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  Widget _buildVerseOfDaySection() {
    return Obx(() {
      if (verseOfDay.isEmpty) {
        return const SizedBox.shrink();
      }
      return VerseOfDayCard(
        verse: verseOfDay['verse'],
        insight: verseOfDay['insight'],
      );
    });
  }

  Widget _buildLearningSection() {
    return CompactGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grow Your Faith',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedGradientButton(
                  text: 'Theology Game',
                  icon: Icons.school,
                  onPressed: () => Get.to(() => const TheologyCardsScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedGradientButton(
                  text: 'Apologetics',
                  icon: Icons.shield,
                  onPressed: () => Get.to(() => const ApologeticsResourcesScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 800.ms).slideX(begin: 0.2);
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
  } 

void showVerseOptions(BuildContext context, Verse verse) {
  final bibleController = Get.find<BibleController>();
  final chapter = verse.chapterNumber;
    final verseNum = verse.verseNumber;
  final formattedRef = "${verse.bookName.toLowerCase()}/$chapter-$verseNum";

  print('Available book names: $formattedRef');

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${verse.bookName} $chapter:$verseNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),          const SizedBox(height: 16),
          _buildLinkTile("Interlinear", "https://biblehub.com/interlinear/$formattedRef.htm"),
          _buildLinkTile("Lexicon", "https://biblehub.com/lexicon/$formattedRef.htm"),
          _buildLinkTile("Strong's", "https://biblehub.com/strongs/$formattedRef.htm"),
      _buildLinkTile("Commentary", "https://biblehub.com/commentaries/$formattedRef.htm"),
      // _buildLinkTile("Videos", "https://www.youtube.com/results?search_query=${Uri.encodeComponent('${book.name} $chapter:$verseNum bible explanation')}"),
      // if (book.testament==Testament.old) ...[
      //   _buildLinkTile("Hebrew", "https://biblehub.com/hebrew/$formattedRef.htm"),
      // ] else ...[
      //   _buildLinkTile("Greek", "https://biblehub.com/greek/$formattedRef.htm"),
      // ],
         
        ],
      ),
    ),
  );
}

Widget _buildLinkTile(String title, String url) {
  return ListTile(
    title: Text(title),
    trailing: const Icon(Icons.open_in_new),
    onTap: () {
      Get.to(() => VerseWebViewScreen(title: title, url: url));
    },
  );
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
