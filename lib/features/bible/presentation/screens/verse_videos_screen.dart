import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/verse.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class VerseVideosScreen extends StatelessWidget {
  final Verse verse;

  const VerseVideosScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final videoQueries = _generateVideoQueries();

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
                  gradient: AppColors.errorGradient,
                ),
                child: FlexibleSpaceBar(
                  title: Text(
                    'Videos',
                    style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildVerseCard().animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),
                    ...videoQueries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final query = entry.value;
                      return _buildVideoCard(context, query)
                          .animate(delay: (index * 100).ms)
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: 0.3);
                    }),
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
              gradient: AppColors.errorGradient,
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
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoQuery query) {
    return SmallGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _launchYouTube(context, query.searchQuery),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.errorGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              query.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  query.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  query.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_circle_filled,
            color: AppColors.error,
            size: 24,
          ),
        ],
      ),
    );
  }

  List<VideoQuery> _generateVideoQueries() {
    final reference = '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}';

    return [
      VideoQuery(
        title: 'Verse Explanation',
        description: 'General explanations and teachings',
        icon: Icons.school,
        searchQuery: '$reference bible verse explanation',
      ),
      VideoQuery(
        title: 'Commentary',
        description: 'Biblical commentary and analysis',
        icon: Icons.comment,
        searchQuery: '$reference bible commentary',
      ),
      VideoQuery(
        title: 'Sermons',
        description: 'Sermons and preaching',
        icon: Icons.church,
        searchQuery: '$reference sermon preaching',
      ),
      VideoQuery(
        title: 'Study',
        description: 'In-depth Bible study',
        icon: Icons.book,
        searchQuery: '$reference bible study',
      ),
      // VideoQuery(
      //   title: 'Hebrew/Greek',
      //   description: 'Original language insights',
      //   icon: Icons.language,
      //   searchQuery: '$reference ${verse.testament.name == 'old' ? 'hebrew' : 'greek'} original language',
      // ),
      VideoQuery(
        title: 'Context',
        description: 'Historical and cultural context',
        icon: Icons.history,
        searchQuery: '$reference bible historical context',
      ),
    ];
  }

  void _launchYouTube(BuildContext context, String query) {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.youtube.com/results?search_query=$encodedQuery';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoWebViewScreen(title: 'Videos', url: url),
      ),
    );
  }
}

class VideoQuery {
  final String title;
  final String description;
  final IconData icon;
  final String searchQuery;

  VideoQuery({
    required this.title,
    required this.description,
    required this.icon,
    required this.searchQuery,
  });
}

class VideoWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const VideoWebViewScreen({super.key, required this.title, required this.url});

  @override
  State<VideoWebViewScreen> createState() => _VideoWebViewScreenState();
}

class _VideoWebViewScreenState extends State<VideoWebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.setBackgroundColor(_getWebViewBackgroundColor());
  }

  Color _getWebViewBackgroundColor() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF2A2A2A) 
            : Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.reload(),
          ),
        ],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}