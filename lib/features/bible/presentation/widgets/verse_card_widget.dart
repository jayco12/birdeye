import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../application/bible_controller.dart';
import '../../domain/entities/verse.dart';
import '../screens/ai_verse_analysis_screen.dart';
import '../screens/verse_notes_screen.dart';
import '../screens/verse_tools_screen.dart';
import '../widgets/interactive_verse_text.dart';

class VerseCardWidget extends StatelessWidget {
  final Verse verse;
  final bool showBookReference;
  final String? highlightQuery;
  final VoidCallback? onTap;
 final bool showActions;
  const VerseCardWidget({
    super.key,
    required this.verse,
    this.showBookReference = false,
    this.highlightQuery,
    this.onTap,
      this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BibleController>();
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildVerseText(),
          const SizedBox(height: 12),
           Obx(() {
            if (controller.readMode.value) {
              return const SizedBox.shrink();
            }
            return _buildActionButtons(context);
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${verse.verseNumber}',
              style: AppTextStyles.verseNumber.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            showBookReference 
                ? '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}'
                : '${verse.chapterNumber}:${verse.verseNumber}',
            style: AppTextStyles.verseReference,
          ),
        ),
        if (verse.translation.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              verse.translation,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerseText() {
    if (highlightQuery != null && highlightQuery!.isNotEmpty) {
      return _buildHighlightedText();
    }
    
    return InteractiveVerseText(
      verse: verse,
      baseStyle: AppTextStyles.verseText,
    );
  }

  Widget _buildHighlightedText() {
    final text = verse.text;
    final query = highlightQuery!.toLowerCase();
    final textLower = text.toLowerCase();
    
    if (!textLower.contains(query)) {
      return Text(text, style: AppTextStyles.verseText);
    }

    final spans = <TextSpan>[];
    int start = 0;
    
    while (start < text.length) {
      final index = textLower.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: AppTextStyles.verseText,
        ));
        break;
      }
      
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: AppTextStyles.verseText,
        ));
      }
      
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: AppTextStyles.verseText.copyWith(
          backgroundColor: AppColors.accent.withOpacity(0.3),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ));
      
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final controller = Get.find<BibleController>();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          icon: Icons.lightbulb, // Or another icon like Icons.lightbulb_outline
          label: 'Verse Analysis',
          onPressed: () => _showAIVerseAnalysis(context),
        ),
        _buildActionButton(
          icon: Icons.note_add,
          label: 'Notes',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseNotesScreen(verse: verse),
            ),
          ),
        ),
        Obx(() => _buildActionButton(
          icon: controller.isBookmarked(verse) 
              ? Icons.bookmark 
              : Icons.bookmark_border,
          label: 'Bookmark',
          isActive: controller.isBookmarked(verse),
          onPressed: () => controller.toggleBookmark(verse),
        )),
        _buildActionButton(
          icon: Icons.build,
          label: 'Tools',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseToolsScreen(verse: verse),
            ),
          ),
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onPressed: () => _shareVerse(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
              ? AppColors.primary 
              : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  void _showAIVerseAnalysis(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            AIVerseAnalysisScreen(verse: verse),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _shareVerse() {
    Get.snackbar(
      'Share Verse',
      'Sharing functionality will be implemented soon!',
      backgroundColor: AppColors.info.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}