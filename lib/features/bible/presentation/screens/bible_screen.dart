import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../../../core/global_widgets/loading_states.dart';
import '../../../apologetics/presentation/screens/webview_screen.dart';
import '../../application/bible_controller.dart';
import '../../domain/entities/verse.dart';
import 'offline_manager_screen.dart';
import 'bookmarks_screen.dart';
import 'search_results_screen.dart';
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
  final FocusNode searchFocusNode = FocusNode();
  final RxString inputText = ''.obs;
  final TextEditingController verseInputController = TextEditingController();
  final RxMap<String, dynamic> verseOfDay = <String, dynamic>{}.obs;
  final RxInt _selectedIndex = 0.obs;

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
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
      body: Obx(() {
        switch (_selectedIndex.value) {
          case 0:
            // Bible Tab: Only show the verses section
            return Container(
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
                         _buildAppGuide(),
          const SizedBox(height: 12),
                        _buildCompactTopSection(),
                        const SizedBox(height: 12),
                        _buildTheologicalInsights(context),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          case 1:
            // Learning Features Tab - For example, show compact top section only
            return Container(
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
                        _buildSelectionSection(),
                        _buildVersesSection(),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          // Placeholder for another tab (e.g. Settings)
          default:
            return Container();
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: _selectedIndex.value,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_stories),
                label: 'Bible',
              ),
            ],
          )),
      floatingActionButton:
          _selectedIndex.value == 0 ? _buildFloatingActions() : null,
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
            'Bird Eye Bible',
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
          icon: Obx(() => Icon(
                controller.readMode.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white,
              )),
          onPressed: () {
            controller.readMode.toggle();
          },
        ),
        // IconButton(
        //   icon: const Icon(Icons.compare_arrows, color: Colors.white),
        //   onPressed: () => Get.to(() => const BibleComparisonScreen()),
        // ),
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
                  items: controller.books
                      .map((book) => DropdownMenuItem(
                            value: book,
                            child: Text(book.name,
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 11)),
                          ))
                      .toList(),
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
                  items: controller.chapters
                      .map((chapter) => DropdownMenuItem(
                            value: chapter,
                            child: Text('${chapter.chapterNumber}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 11)),
                          ))
                      .toList(),
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
                  items: ['NET', 'KJV', 'ASV', 'BSB', 'LSV']
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 11)),
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
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.primary, size: 12),
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
  
Widget _buildTheologicalInsights(BuildContext context) {
  final insights = [
    {
      'title': 'Deus Absconditus',
      'subtitle': 'The Hidden God',
      'description':
          '“Deus absconditus” (Latin: "hidden God") refers to the Christian theological concept that God’s true nature is fundamentally unknowable. This concept emphasizes the mystery and majesty of God beyond human comprehension.',
      'link': 'https://en.wikipedia.org/wiki/Deus_absconditus',
    },
    {
      'title': 'Imago Dei',
      'subtitle': 'Image of God',
      'description':
          'The term “Imago Dei” refers to the belief that humans are created in the image of God. This concept highlights human dignity, moral responsibility, and the unique relationship between God and humanity.',
      'link': 'https://en.wikipedia.org/wiki/Image_of_God',
    },
    {
      'title': 'Sola Scriptura',
      'subtitle': 'Scripture Alone',
      'description':
          'Sola Scriptura is the theological principle that the Bible alone is the ultimate authority in matters of faith and practice. It underlines the importance of Scripture over tradition or church authority.',
      'link': 'https://en.wikipedia.org/wiki/Sola_Scriptura',
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' Theological Insights...',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['title']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight['subtitle']!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight['description']!,
                     style: AppTextStyles.bodySmall.copyWith(
    fontSize: 12,               
    fontWeight: FontWeight.w400,
    color: Colors.grey[900],    
    height: 1.5,                 
    letterSpacing: 0.3,      
    fontStyle: FontStyle.normal, 
  ),
  textAlign: TextAlign.justify,
),
                    const SizedBox(height: 4),
                    GestureDetector(
                       onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(
          url: insight['link']!,
          title: 'Resources',
        ),
      ),
    );
  },
                      child: Text(
                        'Read more',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    ),
  );
}

  Widget _buildVerseCard(Verse verse, int index, BuildContext context) {
    return VerseCardWidget(
      verse: verse,
      showBookReference: true,
      highlightQuery: controller.highlightQuery.value,
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

  void clearInput() {
    verseInputController.clear();
    inputText.value = '';
    _focusSearchField();
  }

  void goToSearchScreen(String query) {
Get.to(() => SearchResultsScreen(searchQuery: query))?.then((_) {
  verseInputController.clear();
  controller.verses.clear(); // ensure controller is empty too
});
  }

  // Observable to control showing the guide
RxBool _showGuide = true.obs;

Widget _buildCompactTopSection() {
  return GlassCard(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         
          _buildProgressHeader(),
          const SizedBox(height: 12),
          _buildSearchSection(),
          const SizedBox(height: 12),
          _buildVerseOfDay(),
          const SizedBox(height: 12),
          _buildLearningFeatures(),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
}



Widget _buildAppGuide() {
  return Obx(() {
    if (!_showGuide.value) return const SizedBox.shrink();

    final PageController pageController = PageController();
    final RxInt currentPage = 0.obs;

    final slides = [
      {
        'title': 'Navigation & Tools',
        'content': [
          '- Use the bottom navigation bar to switch between Bible and Learning tabs.',
          '- Toggle tools like Read Mode using the eye icon on the AppBar.',
          '- Swipe right on verses to move to the next verse.',
          '- Tap a verse to highlight or bookmark it.',
        ],
      },
      {
        'title': 'Search',
        'content': [
          '- Enter a reference like "John 3:16" or a keyword in the search bar.',
          '- Press Enter or tap the search icon to view results.',
          '- Clear your input using the small cancel button in the search bar.',
        ],
      },
      {
        'title': 'Verse of the Day',
        'content': [
          '- The Verse of the Day is shown below the search bar.',
          '- Tap it to see a detailed insight for reflection.',
        ],
      },
      {
        'title': 'Learning Features',
        'content': [
          '- Theology Game: Test your knowledge of theological concepts in a fun quiz format.',
          '- Apologetics: Access curated resources and lessons to learn about defending faith logically and biblically.',
        ],
      },
      {
        'title': 'Bookmarks & Notes',
        'content': [
          '- Bookmark verses for quick access using the bookmark button.',
          '- Access your notes via the “All Notes” menu.',
          '- Manage offline content via the “Offline Manager”.',
        ],
      },
      {
        'title': 'Quick Tips',
        'content': [
          '- You can dismiss this guide anytime using the close button.',
          '- Experiment with Read Mode to focus on verses without distractions.',
          '- All features are interactive, so feel free to tap and explore!',
        ],
      },
    ];

    return Dismissible(
      key: const ValueKey('appGuide'),
      onDismissed: (_) => _showGuide.value = false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(
            maxHeight: 270, // bounding height to prevent infinite height errors
            minHeight: 200,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.info, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'App Guide',
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showGuide.value = false,
                    child: const Icon(Icons.close, color: AppColors.primary),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // Slide content
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) => currentPage.value = index,
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔹 ${slide['title']}',
                          style: AppTextStyles.bodySmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List<Widget>.from(
                          (slide['content'] as List<String>).map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                text,
                                style: AppTextStyles.bodySmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Arrows & page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (currentPage.value > 0) {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Obx(
                    () => Text(
                      '${currentPage.value + 1}/${slides.length}',
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (currentPage.value < slides.length - 1) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  });
}

// 2️⃣ Progress Header
Widget _buildProgressHeader() {
  return Obx(() {
    final controller = Get.find<GamificationController>();
    final progress = controller.userProgress.value;
    return Row(
      children: [
        // Streak
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department,
                  color: Colors.white, size: 14),
              const SizedBox(width: 2),
              Text('${progress.currentStreak}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Levels
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
                color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        // Points
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
              Text('${progress.totalPoints}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  });
}

// 3️⃣ Search Section
Widget _buildSearchSection() {
  return Row(
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
            focusNode: searchFocusNode,
            controller: verseInputController,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search verse (e.g. John 3:16)',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.primary, size: 18),
              suffixIcon: inputText.value.isNotEmpty
                  ? GestureDetector(
                      onTap: clearInput,
                      child: const Icon(Icons.cancel,
                          color: AppColors.textTertiary),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: (value) {
              final trimmed = value.trim();
              if (trimmed.isNotEmpty) {
                goToSearchScreen(trimmed);
              }
            },
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
                goToSearchScreen(input);

              } else {
                _focusSearchField();
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
  );
}

// 4️⃣ Verse of the Day
Widget _buildVerseOfDay() {
  return Obx(() {
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
  });
}

// 5️⃣ Learning Features Section
Widget _buildLearningFeatures() {
  return Column(
    children: [
      Row(
        children: [
          const Icon(Icons.school, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Learning Features',
            style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.primary),
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
                  fontSize: 10),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              icon: Icons.psychology,
              title: 'Theology Game',
              gradient: AppColors.primaryGradient,
              onTap: () => Get.to(() => const TheologyCardsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFeatureCard(
              icon: Icons.shield,
              title: 'Apologetics',
              gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.tertiary]),
              onTap: () => Get.to(() => const ApologeticsResourcesScreen()),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildFeatureCard({
  required IconData icon,
  required String title,
  required Gradient gradient,
  required VoidCallback onTap,
}) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(title,
                style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
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
    final currentIndex = chapters
        .indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);

    if (currentIndex < chapters.length - 1) {
      controller.selectChapter(chapters[currentIndex + 1]);
    }
  }

  void _navigateToPreviousChapter() {
    final currentChapter = controller.selectedChapter.value;
    if (currentChapter == null) return;

    final chapters = controller.chapters;
    final currentIndex = chapters
        .indexWhere((c) => c.chapterNumber == currentChapter.chapterNumber);

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
  reference = reference.replaceAll(
      RegExp(r'([a-zA-Z])\.'), r'\1'); // remove periods like "Jn." → "Jn"
  reference = reference
      .replaceAll(RegExp(r'(KJV|NIV|ESV|NASB|MSG)$'), '')
      .trim(); // strip trailing translation

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


// TODO: Integrate a function for verse contributions. 
// TODO: Add a function to handle verse contributions from users, allowing them to suggest edits or additions to verses. This could involve a form where users can submit their contributions, which would then be reviewed by moderators before being added to the database.
// TODO: Implement a function for street evangelism resources.
// TODO: Implement a function to draw original bible writings. s