import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../../../core/global_widgets/loading_states.dart';
import '../../application/bible_controller.dart';
import '../../data/models/verse_model.dart';
import '../../domain/entities/verse.dart';
import '../widgets/verse_card_widget.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  const SearchResultsScreen({Key? key, required this.searchQuery})
      : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final BibleController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchVerses(widget.searchQuery);
      
    });
  }
@override
void dispose() {
  super.dispose();
  
  controller.verses.clear(); 
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
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
            'Search Results',
            style: AppTextStyles.displayMedium.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          background: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      ;
                      controller.searchVerses(widget.searchQuery);
                    },
                    child: Icon(
                      Icons.search,
                      size: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        '${controller.verses.length} results for "${widget.searchQuery}"',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterOptions,
        ),
      ],
    );
  }

  Widget _buildResultsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      } else if (controller.error.value.isNotEmpty) {
        return _buildErrorState();
      } else if (controller.verses.isEmpty) {
        return _buildEmptyState();
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final verse = controller.verses[index]; // Verse type

            // Internal widget for search result
            Widget searchVerseTile(Verse verse) {
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book + chapter reference
                    Text(
                      '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Verse text
                    Text(
                      verse.text,
                      style:
                          const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
              );
            }

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: searchVerseTile(verse),
                  ),
                ),
              ),
            );
          },
          childCount: controller.verses.length,
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: SearchLoadingWidget(query: widget.searchQuery),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Search Error',
                style:
                    AppTextStyles.headingSmall.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                controller.error.value,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedGradientButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: () => controller.searchVerses(widget.searchQuery),
              ),
            ],
          ),
        ).animate().fadeIn().shake(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'No verses found for "${widget.searchQuery}".\nTry different keywords or check spelling.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedGradientButton(
                text: 'Back to Bible',
                icon: Icons.arrow_back,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }

  void _showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Results',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Old Testament', Icons.book),
            _buildFilterOption('New Testament', Icons.auto_stories),
            _buildFilterOption('Sort by Relevance', Icons.sort),
            _buildFilterOption(
                'Sort by Book Order', Icons.format_list_numbered),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AnimatedGradientButton(
                text: 'Apply Filters',
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Implement filter logic
        Get.back();
      },
    );
  }
}
