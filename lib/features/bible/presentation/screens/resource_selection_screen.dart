import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/entities/bible_resource.dart';
import '../../data/datasources/bible_resources.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class ResourceSelectionScreen extends StatelessWidget {
  final Verse verse;
  final ResourceType resourceType;
  final String title;

  const ResourceSelectionScreen({
    super.key,
    required this.verse,
    required this.resourceType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final resourceUrls = BibleResources.generateUrls(verse, resourceType);

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
                    title,
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
                    ...resourceUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final resourceUrl = entry.value;
                      return _buildResourceCard(context, resourceUrl)
                          .animate(delay: (index * 100).ms)
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: 0.3);
                    }).toList(),
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

  Widget _buildResourceCard(BuildContext context, ResourceUrl resourceUrl) {
    return SmallGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _openResource(context, resourceUrl),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: _getResourceGradient(resourceUrl.resource.name),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _getResourceIcon(resourceUrl.resource.name),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resourceUrl.resource.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resourceUrl.resource.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _getResourceIcon(String resourceName) {
    if (resourceName.contains('BibleHub')) {
      return const Icon(Icons.hub, color: Colors.white, size: 20);
    } else if (resourceName.contains('Blue Letter Bible')) {
      return const Icon(Icons.library_books, color: Colors.white, size: 20);
    } else if (resourceName.contains('Logos')) {
      return const Icon(Icons.school, color: Colors.white, size: 20);
    }
    return const Icon(Icons.book, color: Colors.white, size: 20);
  }

  Gradient _getResourceGradient(String resourceName) {
    if (resourceName.contains('BibleHub')) {
      return AppColors.infoGradient;
    } else if (resourceName.contains('Blue Letter Bible')) {
      return AppColors.primaryGradient;
    } else if (resourceName.contains('Logos')) {
      return AppColors.warningGradient;
    }
    return AppColors.successGradient;
  }

  void _openResource(BuildContext context, ResourceUrl resourceUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceWebViewScreen(
          title: resourceUrl.resource.name,
          url: resourceUrl.url,
        ),
      ),
    );
  }
}

class ResourceWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const ResourceWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<ResourceWebViewScreen> createState() => _ResourceWebViewScreenState();
}

class _ResourceWebViewScreenState extends State<ResourceWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
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
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}