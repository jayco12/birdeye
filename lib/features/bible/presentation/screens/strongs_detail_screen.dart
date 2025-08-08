import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/verse.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';

class StrongsDetailScreen extends StatefulWidget {
  final String word;
  final String strongsNumber;
  final Verse verse;
  final int position;

  const StrongsDetailScreen({
    super.key,
    required this.word,
    required this.strongsNumber,
    required this.verse,
    required this.position,
  });

  @override
  State<StrongsDetailScreen> createState() => _StrongsDetailScreenState();
}

class _StrongsDetailScreenState extends State<StrongsDetailScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final lexiconUrl = _buildBibleHubLexiconUrl();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(lexiconUrl));
  }

  String _buildBibleHubLexiconUrl() {
    // BibleHub Strong's lexicon URL format
    final isHebrew = widget.strongsNumber.startsWith('H');
    final number = widget.strongsNumber.substring(1);
    
    if (isHebrew) {
      return 'https://biblehub.com/hebrew/$number.htm';
    } else {
      return 'https://biblehub.com/greek/$number.htm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: widget.strongsNumber.startsWith('H') 
                    ? AppColors.warningGradient 
                    : AppColors.infoGradient,
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  '${widget.word} - ${widget.strongsNumber}',
                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
                ),
                centerTitle: true,
                actions: [
                  FloatingActionBubble(
                    icon: Icons.refresh,
                    onPressed: () => controller.reload(),
                  ).animate().scale(duration: 300.ms),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildWordInfoCard().animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLexiconView().animate().fadeIn(duration: 800.ms, delay: 200.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordInfoCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: widget.strongsNumber.startsWith('H') 
                      ? AppColors.warningGradient 
                      : AppColors.infoGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.strongsNumber.startsWith('H') ? Icons.language : Icons.translate,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.word,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: widget.strongsNumber.startsWith('H') 
                            ? AppColors.warningGradient 
                            : AppColors.infoGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.strongsNumber,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.book, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'From ${widget.verse.bookName} ${widget.verse.chapterNumber}:${widget.verse.verseNumber}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.strongsNumber.startsWith('H') 
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.strongsNumber.startsWith('H') 
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Text(
              widget.strongsNumber.startsWith('H') ? 'HEBREW' : 'GREEK',
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.strongsNumber.startsWith('H') 
                    ? AppColors.warning
                    : AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLexiconView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: WebViewWidget(controller: controller),
    );
  }
}