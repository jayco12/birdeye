import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/bible_resource.dart';
import 'verse_videos_screen.dart';
import 'resource_selection_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class VerseToolsScreen extends StatelessWidget {
  final Verse verse;

  const VerseToolsScreen({super.key, required this.verse});

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildVerseCard().animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                    const SizedBox(height: 24),
                    _buildToolsGrid(context).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                  ],
                ),
              ),
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
              '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            verse.text,
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.translate, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                verse.translation,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    final tools = [
      ToolItem('Strong\'s Numbers', Icons.book, ResourceType.strongs, AppColors.primaryGradient),
      ToolItem('Interlinear', Icons.translate, ResourceType.interlinear, AppColors.accentGradient),
      ToolItem('Lexicon', Icons.library_books, ResourceType.lexicon, AppColors.successGradient),
      ToolItem('Commentary', Icons.comment, ResourceType.commentary, AppColors.warningGradient),
      ToolItem('Historical Context', Icons.history, ResourceType.context, AppColors.infoGradient),
      ToolItem('Miscellaneous Aid', Icons.help_outline, ResourceType.miscellaneous, AppColors.primaryGradient),
      ToolItem('Early Church Fathers', Icons.church, ResourceType.earlyFathers, AppColors.accentGradient),
      ToolItem('Videos', Icons.play_circle, null, AppColors.errorGradient),

    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return CompactGlassCard(
          onTap: () => tool.title == 'Videos' 
              ? _openVideosScreen(context)
              : _openResourceSelection(context, tool.title, tool.resourceType!),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: tool.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  tool.icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tool.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate(delay: (index * 100).ms)
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }



  void _openVideosScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseVideosScreen(verse: verse),
      ),
    );
  }

  void _openResourceSelection(BuildContext context, String title, ResourceType resourceType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceSelectionScreen(
          verse: verse,
          resourceType: resourceType,
          title: title,
        ),
      ),
    );
  }
}

class ToolItem {
  final String title;
  final IconData icon;
  final ResourceType? resourceType;
  final Gradient gradient;

  ToolItem(this.title, this.icon, this.resourceType, this.gradient);
}

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: controller),
    );
  }
}