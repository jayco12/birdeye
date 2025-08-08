import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../../application/bible_controller.dart';
import '../../domain/entities/verse.dart';
import 'verse_tools_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class BookmarksScreen extends GetView<BibleController> {
  const BookmarksScreen({super.key});

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
                    'Bookmarks',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
              actions: [
                Obx(() => controller.bookmarkedVerses.isNotEmpty
                    ? FloatingActionBubble(
                        icon: Icons.delete_sweep,
                        onPressed: _showClearAllDialog,
                      ).animate().scale(duration: 300.ms)
                    : const SizedBox()),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  if (controller.bookmarkedVerses.isEmpty) {
                    return _buildEmptyState().animate().fadeIn(duration: 800.ms).scale();
                  }

                  return Column(
                    children: controller.bookmarkedVerses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final verse = entry.value;
                      return _buildBookmarkCard(verse, index)
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
              Icons.bookmark_border,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No bookmarks yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon on any verse\nto save it here',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Verse verse, int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Get.to(() => VerseToolsScreen(verse: verse)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              FloatingActionBubble(
                icon: Icons.bookmark,
                onPressed: () => controller.toggleBookmark(verse),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verse.text,
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.5,
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.translate, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                verse.translation,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Bookmarks',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove all bookmarks?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          AnimatedGradientButton(
            text: 'Clear All',
            onPressed: () {
              controller.bookmarkedVerses.clear();
              Get.back();
            },
            gradient: AppColors.errorGradient,
          ),
        ],
      ),
    );
  }
}