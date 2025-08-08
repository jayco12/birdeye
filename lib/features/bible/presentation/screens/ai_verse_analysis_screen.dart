import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../../../core/global_widgets/reusable_components.dart';
import '../../application/ai_controller.dart';
import '../../domain/entities/verse.dart';

class AIVerseAnalysisScreen extends StatelessWidget {
  final Verse verse;

  const AIVerseAnalysisScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final aiController = Get.put(AIController());
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildVerseCard(),
                  const SizedBox(height: 20),
                  _buildAIFeatureGrid(aiController),
                  const SizedBox(height: 20),
                  _buildInsightSection(aiController),
                  const SizedBox(height: 20),
                  _buildQuestionsSection(aiController),
                  const SizedBox(height: 20),
                  _buildWordAnalysisSection(aiController),
                  const SizedBox(height: 20),
                  _buildDevotionalSection(aiController),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
            'Bible Study Insight',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildVerseCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReferenceChip(
                text: '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                gradient: AppColors.secondaryGradient,
              ),
              const Spacer(),
              const PulsingDot(color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verse.text,
            style: AppTextStyles.verseText,
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeatureGrid(AIController aiController) {
    final features = [
      {
        'title': 'Insights',
        'icon': Icons.psychology,
        'color': AppColors.primary,
        'action': () => aiController.generateVerseInsight(verse),
      },
      {
        'title': 'Study Questions',
        'icon': Icons.quiz,
        'color': AppColors.secondary,
        'action': () => aiController.generateStudyQuestions(verse),
      },
   
      {
        'title': 'Word Analysis',
        'icon': Icons.translate,
        'color': AppColors.accent,
        'action': () => aiController.generateWordAnalysis(verse),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return GlassCard(
          onTap: feature['action'] as VoidCallback,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FeatureIcon(
                icon: feature['icon'] as IconData,
                color: feature['color'] as Color,
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightSection(AIController aiController) {
    return Obx(() {
      if (aiController.isGeneratingInsight.value) {
        return _buildLoadingCard('loading...');
      }
      
      if (aiController.currentInsight.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.psychology,
              title: 'Insights',
              iconColor: AppColors.primary,
              onClose: () => aiController.clearCurrentInsight(),
            ),
            const SizedBox(height: 12),
            Text(
              aiController.currentInsight.value,
              style: AppTextStyles.aiInsightBody,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionsSection(AIController aiController) {
    return Obx(() {
      if (aiController.isGeneratingQuestions.value) {
        return _buildLoadingCard('Generating study questions...');
      }
      
      if (aiController.currentQuestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.quiz,
              title: 'Study Questions',
              iconColor: AppColors.secondary,
              onClose: () => aiController.clearCurrentQuestions(),
            ),
            const SizedBox(height: 12),
            ...aiController.currentQuestions.asMap().entries.map((entry) {
              return NumberedListItem(
                number: entry.key + 1,
                text: entry.value,
                accentColor: AppColors.secondary,
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildDevotionalSection(AIController aiController) {
    return Obx(() {
      if (aiController.isGeneratingDevotional.value) {
        return _buildLoadingCard('Creating personal devotional...');
      }
      
      if (aiController.currentDevotional.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.favorite,
              title: 'Personal Devotional',
              iconColor: AppColors.tertiary,
              onClose: () => aiController.clearCurrentDevotional(),
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: aiController.currentDevotional.value,
              styleSheet: MarkdownStyleSheet(
                p: AppTextStyles.aiInsightBody,
                h1: AppTextStyles.headingSmall,
                h2: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingCard(String message) {
    return GlassCard(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWordAnalysisSection(AIController aiController) {
    return Obx(() {
      if (aiController.isGeneratingWordAnalysis.value) {
        return _buildLoadingCard('Analyzing original language words...');
      }
      
      if (aiController.currentWordAnalysis.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.translate,
              title: 'Word Analysis',
              iconColor: AppColors.accent,
              onClose: () => aiController.clearCurrentWordAnalysis(),
            ),
            const SizedBox(height: 12),
            ...aiController.currentWordAnalysis.asMap().entries.map((entry) {
              final word = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word['word'] ?? '',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${word['original'] ?? ''})',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word['analysis'] ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}