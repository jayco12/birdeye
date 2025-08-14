import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../application/scholarly_controller.dart';
import '../../domain/entities/verse.dart';

class AIVerseAnalysisScreen extends StatelessWidget {
  final Verse verse;

  const AIVerseAnalysisScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScholarlyController());
    controller.loadVerseAnalysis(verse);
    
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
                  _buildAnalysisSection(controller),
                  const SizedBox(height: 20),
                  _buildQuestionsSection(controller),
                  const SizedBox(height: 20),
                  _buildWebViewSection(controller),
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
            'Scholarly Analysis',
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
          Text(
            '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            verse.text,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAnalysisSection(ScholarlyController controller) {
    return Obx(() {
      if (controller.isLoadingAnalysis.value) {
        return _buildLoadingCard('Loading scholarly analysis...');
      }
      
      if (controller.currentAnalysis.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Scholarly Analysis',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.currentAnalysis.value,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestionsSection(ScholarlyController controller) {
    return Obx(() {
      if (controller.currentQuestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Study Questions',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.currentQuestions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodyMedium,
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

  Widget _buildWebViewSection(ScholarlyController controller) {
    return Obx(() {
      if (controller.studyUrl.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.web, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Full Study Resource',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15')
                    ..enableZoom(true)
                    ..setNavigationDelegate(NavigationDelegate(
                      onNavigationRequest: (request) => NavigationDecision.navigate,
                    ))
                    ..loadRequest(Uri.parse(controller.studyUrl.value)),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer(),
                    ),
                    Factory<HorizontalDragGestureRecognizer>(
                      () => HorizontalDragGestureRecognizer(),
                    ),
                    Factory<PanGestureRecognizer>(
                      () => PanGestureRecognizer(),
                    ),
                  },
                ),
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


}