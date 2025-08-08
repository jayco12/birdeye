import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../application/bible_controller.dart';
import '../../domain/entities/verse.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class BibleComparisonScreen extends GetView<BibleController> {
  const BibleComparisonScreen({super.key});

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
                    'Bible Comparison',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
              actions: [
                FloatingActionBubble(
                  icon: Icons.add,
                  onPressed: () => _showAddTranslationDialog(context),
                ).animate().scale(duration: 300.ms),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildReferenceInput().animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                  _buildTranslationTabs().animate().fadeIn(duration: 700.ms, delay: 100.ms),
                  _buildComparisonView().animate().fadeIn(duration: 800.ms, delay: 200.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CompactGlassCard(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter verse reference (e.g., John 3:16)',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                onSubmitted: (value) => controller.loadVerseForComparison(value),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedGradientButton(
              text: 'Load',
              onPressed: () => controller.loadVerseForComparison(''),
              icon: Icons.search,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationTabs() {
    return Obx(() {
      final translations = controller.selectedTranslationsForComparison;
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: translations.length,
          itemBuilder: (context, index) {
            final translation = translations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                label: Text(translation),
                onDeleted: translations.length > 1 
                    ? () => controller.removeTranslationFromComparison(translation)
                    : null,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildComparisonView() {
    return Obx(() {
      final verses = controller.comparisonVerses;
      if (verses.isEmpty) {
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compare, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter a verse reference\nto compare translations',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: verses.asMap().entries.map((entry) {
            final index = entry.key;
            final verse = entry.value;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 16),
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
                      verse.translation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verse.text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (index * 100).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3);
          }).toList(),
        ),
      );
    });
  }

  void _showAddTranslationDialog(BuildContext context) {
    final availableTranslations = ['KJV', 'NIV', 'ESV', 'NASB', 'NLT', 'MSG', 'AMP'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Translation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableTranslations.map((translation) {
            return ListTile(
              title: Text(translation),
              onTap: () {
                controller.addTranslationToComparison(translation);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}