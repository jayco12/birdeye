import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../data/services/apologetics_service.dart';
import 'video_player_screen.dart';
import 'webview_screen.dart';
import 'audio_player_screen.dart';

class ApologeticsResourcesScreen extends StatefulWidget {
  const ApologeticsResourcesScreen({super.key});

  @override
  State<ApologeticsResourcesScreen> createState() => _ApologeticsResourcesScreenState();
}

class _ApologeticsResourcesScreenState extends State<ApologeticsResourcesScreen> {
  final ApologeticsService _service = ApologeticsService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ApologeticsResource> _resources = [];
  bool _isLoading = false;
  String _selectedTopic = '';

  @override
  void initState() {
    super.initState();
    _loadPopularResources();
  }

  Future<void> _loadPopularResources() async {
    setState(() => _isLoading = true);
    
    try {
      final resources = await _service.searchResources('Christian apologetics evidence');
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchTopic(String topic) async {
    setState(() {
      _isLoading = true;
      _selectedTopic = topic;
    });
    
    try {
      final resources = await _service.searchResources(topic);
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildSearchSection()),
            SliverToBoxAdapter(child: _buildTopicChips()),
            _isLoading 
                ? SliverFillRemaining(child: _buildLoadingState())
                : _buildResourcesList(),
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
            'Apologetics Resources',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search apologetics topics...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _searchTopic(_searchController.text),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: _searchTopic,
      ),
    );
  }

  Widget _buildTopicChips() {
    final topics = _service.getPopularTopics();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Topics',
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              final isSelected = _selectedTopic == topic;
              return GestureDetector(
                onTap: () => _searchTopic(topic),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    topic,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading apologetics resources...'),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    if (_resources.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'No resources found',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for a different topic',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final resource = _resources[index];
            return _buildResourceCard(resource).animate(
              delay: (index * 100).ms,
            ).fadeIn(duration: 600.ms).slideY(begin: 0.3);
          },
          childCount: _resources.length,
        ),
      ),
    );
  }

  Widget _buildResourceCard(ApologeticsResource resource) {
    IconData getResourceIcon() {
      switch (resource.type) {
        case ResourceType.video:
          return Icons.play_circle_fill;
        case ResourceType.book:
          return Icons.menu_book;
        case ResourceType.article:
          return Icons.article;
        case ResourceType.podcast:
          return Icons.podcasts;
      }
    }
    
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _openResource(resource),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              resource.thumbnailUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.surface,
                  child: Icon(getResourceIcon(), size: 64),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(resource.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  resource.type.name.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getTypeColor(resource.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            resource.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            resource.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                resource.channelName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                getResourceIcon(),
                color: _getTypeColor(resource.type),
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getTypeColor(ResourceType type) {
    switch (type) {
      case ResourceType.video:
        return AppColors.primary;
      case ResourceType.book:
        return AppColors.secondary;
      case ResourceType.article:
        return AppColors.accent;
      case ResourceType.podcast:
        return AppColors.tertiary;
    }
  }

  void _openResource(ApologeticsResource resource) {
    switch (resource.type) {
      case ResourceType.video:
        _openVideoPlayer(resource);
        break;
      case ResourceType.book:
      case ResourceType.article:
        _openWebView(resource);
        break;
      case ResourceType.podcast:
        _openAudioPlayer(resource);
        break;
    }
  }
  
  void _openVideoPlayer(ApologeticsResource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoId: resource.videoId,
          title: resource.title,
        ),
      ),
    );
  }
  
  void _openWebView(ApologeticsResource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(
          url: resource.videoUrl,
          title: resource.title,
        ),
      ),
    );
  }
  
  void _openAudioPlayer(ApologeticsResource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(
          url: resource.videoUrl,
          title: resource.title,
        ),
      ),
    );
  }
}