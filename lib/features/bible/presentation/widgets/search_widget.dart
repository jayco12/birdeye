import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../application/bible_controller.dart';
import '../screens/search_results_screen.dart';

class SearchWidget extends StatefulWidget {
  final String? hintText;
  final bool showRecentSearches;
  
  const SearchWidget({
    super.key,
    this.hintText,
    this.showRecentSearches = true,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // Load from local storage - implement as needed
    recentSearches.value = [
      'John 3:16',
      'love',
      'faith',
      'Romans 8',
      'peace',
    ];
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final trimmedQuery = query.trim();
    isSearching.value = true;
    
    // Add to recent searches
    if (!recentSearches.contains(trimmedQuery)) {
      recentSearches.insert(0, trimmedQuery);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
    }
    
    // Navigate to search results
    Get.to(() => SearchResultsScreen(searchQuery: trimmedQuery));
    
    // Perform the search
    final controller = Get.find<BibleController>();
    await controller.searchVerses(trimmedQuery);
    
    isSearching.value = false;
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        if (widget.showRecentSearches) ...[
          const SizedBox(height: 8),
          _buildRecentSearches(),
        ],
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: AppColors.primary, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search verses (e.g. John 3:16 or "love")',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
          Obx(() => isSearching.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _performSearch(_controller.text),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.search, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (recentSearches.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Searches',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => recentSearches.clear(),
                child: Text(
                  'Clear',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: recentSearches.take(5).map((search) {
              return _buildSearchChip(search);
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildSearchChip(String search) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _performSearch(search),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  search,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}