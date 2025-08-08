import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../data/apologetics_content.dart';
import 'apologetics_detail_screen.dart';

class ApologeticsScreen extends StatelessWidget {
  const ApologeticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTopicsGrid(),
                  const SizedBox(height: 20),
                  _buildFeaturedArticle(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: FlexibleSpaceBar(
          title: Text(
            'Apologetics',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildTopicsGrid() {
    final topics = [
      {
        'key': 'existence_of_god',
        'title': 'Existence of God',
        'icon': Icons.psychology,
        'color': AppColors.primary,
        'description': 'Cosmological, teleological, and moral arguments',
      },
      {
        'key': 'problem_of_evil',
        'title': 'Problem of Evil',
        'icon': Icons.help_outline,
        'color': AppColors.secondary,
        'description': 'Addressing suffering and God\'s goodness',
      },
      {
        'key': 'biblical_reliability',
        'title': 'Biblical Reliability',
        'icon': Icons.book,
        'color': AppColors.accent,
        'description': 'Manuscript evidence and historical accuracy',
      },
      {
        'key': 'jesus_resurrection',
        'title': 'Jesus\' Resurrection',
        'icon': Icons.brightness_high,
        'color': AppColors.tertiary,
        'description': 'Historical evidence for the resurrection',
      },
      {
        'key': 'science_faith',
        'title': 'Science & Faith',
        'icon': Icons.science,
        'color': AppColors.primary,
        'description': 'Harmony between science and Christianity',
      },
      {
        'key': 'other_religions',
        'title': 'Other Religions',
        'icon': Icons.public,
        'color': AppColors.secondary,
        'description': 'Comparative religion and truth claims',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return GlassCard(
          onTap: () => _showTopicDetail(context, topic),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topic['color'] as Color, (topic['color'] as Color).withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  topic['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                topic['title'] as String,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                topic['description'] as String,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ).animate(delay: (index * 100).ms).fadeIn().slideY(begin: 0.3);
      },
    );
  }

  Widget _buildFeaturedArticle() {
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
              'FEATURED',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The Kalam Cosmological Argument',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Everything that begins to exist has a cause. The universe began to exist. Therefore, the universe has a cause.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          AnimatedGradientButton(
            text: 'Read More',
            icon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3);
  }

  void _showTopicDetail(BuildContext context, Map<String, dynamic> topic) {
    final content = ApologeticsContentDatabase.content[topic['key']];
    if (content == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApologeticsDetailScreen(content: content, topic: topic),
      ),
    );
  }
}