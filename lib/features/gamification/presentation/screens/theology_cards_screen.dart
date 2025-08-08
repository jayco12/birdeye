import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/global_widgets/animated_widgets.dart';
import '../../application/gamification_controller.dart';

class TheologyCardsScreen extends StatefulWidget {
  const TheologyCardsScreen({super.key});

  @override
  State<TheologyCardsScreen> createState() => _TheologyCardsScreenState();
}

class _TheologyCardsScreenState extends State<TheologyCardsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;
  String _currentDifficulty = 'beginner';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/theology_question_bank_500.json');
      final List<dynamic> allQuestions = jsonDecode(jsonString);
      
      // Filter by current difficulty and get random 7 questions
      final filteredQuestions = allQuestions
          .where((q) => q['difficulty'] == _currentDifficulty)
          .toList();
      
      filteredQuestions.shuffle(Random());
      _cards = filteredQuestions.take(7).cast<Map<String, dynamic>>().toList();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverFillRemaining(
                    child: Column(
                      children: [
                        _buildDifficultySelector(),
                        _buildProgressIndicator(),
                        Expanded(child: _buildCardView()),
                        _buildNavigationButtons(),
                        const SizedBox(height: 20),
                      ],
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
            'Theological Cards - ${_currentDifficulty.toUpperCase()}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['beginner', 'intermediate', 'advanced'].map((difficulty) {
          final isSelected = _currentDifficulty == difficulty;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentDifficulty = difficulty;
                    _currentIndex = 0;
                    _isLoading = true;
                  });
                  _loadQuestions();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    difficulty.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_cards.length, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentIndex 
                    ? AppColors.primary 
                    : AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: _buildCard(card),
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    return GlassCard(
      child: SingleChildScrollView(
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
              card['category'].toString().toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            card['question'],
            style: AppTextStyles.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(
                card['options'][index],
                index,
                card['correctAnswer'] == index,
              ),
            );
          }),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Explanation',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card['explanation'],
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reference: ${card['reference']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3);
  }

  Widget _buildOptionButton(String text, int index, bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect 
              ? AppColors.success 
              : AppColors.primary.withOpacity(0.2),
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: AppTextStyles.bodySmall.copyWith(
                  color: isCorrect ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: AnimatedGradientButton(
                text: 'Previous',
                icon: Icons.arrow_back,
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: AnimatedGradientButton(
              text: _currentIndex < _cards.length - 1 ? 'Next' : 'Complete',
              icon: _currentIndex < _cards.length - 1 ? Icons.arrow_forward : Icons.check,
              onPressed: () {
                if (_currentIndex < _cards.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  final controller = Get.find<GamificationController>();
                  final points = _currentDifficulty == 'beginner' ? 30 : 
                                _currentDifficulty == 'intermediate' ? 50 : 70;
                  controller.addTheologicalProgress(_currentDifficulty, points);
                  
                  // Show completion dialog with option to play again
                  _showCompletionDialog(points);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Great Job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You earned $points theology points!'),
            const SizedBox(height: 16),
            Text(
              'Level: ${_currentDifficulty.toUpperCase()}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _isLoading = true;
              });
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              _loadQuestions();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}