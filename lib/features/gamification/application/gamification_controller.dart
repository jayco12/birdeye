import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/entities/user_progress.dart';

class GamificationController extends GetxController {
  final Rx<UserProgress> userProgress = UserProgress.initial().obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadProgress();
  }

  void recordStudySession() {
    final now = DateTime.now();
    final lastStudy = userProgress.value.lastStudyDate;
    final daysDiff = now.difference(lastStudy).inDays;

    // Only record once per day
    if (daysDiff == 0) return;

    int newStreak = userProgress.value.currentStreak;
    if (daysDiff == 1) {
      newStreak++;
    } else if (daysDiff > 1) {
      newStreak = 1;
    }

    userProgress.value = userProgress.value.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > userProgress.value.longestStreak 
          ? newStreak 
          : userProgress.value.longestStreak,
      totalDaysStudied: userProgress.value.totalDaysStudied + 1,
      totalPoints: userProgress.value.totalPoints + 10,
      lastStudyDate: now,
    );

    _checkAchievements();
    _saveProgress();
  }

  void addTheologicalProgress(String category, int points) {
    final currentProgress = Map<String, int>.from(userProgress.value.categoryProgress);
    currentProgress[category] = (currentProgress[category] ?? 0) + points;

    userProgress.value = userProgress.value.copyWith(
      categoryProgress: currentProgress,
      theologicalDepth: _calculateTheologicalDepth(currentProgress),
      totalPoints: userProgress.value.totalPoints + points,
    );
    
    _saveProgress();
  }

  int _calculateTheologicalDepth(Map<String, int> progress) {
    final totalProgress = progress.values.fold(0, (sum, value) => sum + value);
    return (totalProgress / 100).floor() + 1;
  }

  void _checkAchievements() {
    final achievements = List<String>.from(userProgress.value.achievements);
    
    if (userProgress.value.currentStreak >= 7 && !achievements.contains('week_warrior')) {
      achievements.add('week_warrior');
    }
    if (userProgress.value.currentStreak >= 30 && !achievements.contains('month_master')) {
      achievements.add('month_master');
    }
    if (userProgress.value.totalPoints >= 1000 && !achievements.contains('scholar')) {
      achievements.add('scholar');
    }

    userProgress.value = userProgress.value.copyWith(achievements: achievements);
  }
  
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = {
        'currentStreak': userProgress.value.currentStreak,
        'longestStreak': userProgress.value.longestStreak,
        'totalDaysStudied': userProgress.value.totalDaysStudied,
        'disciplineLevel': userProgress.value.disciplineLevel,
        'theologicalDepth': userProgress.value.theologicalDepth,
        'apologeticsLevel': userProgress.value.apologeticsLevel,
        'categoryProgress': userProgress.value.categoryProgress,
        'achievements': userProgress.value.achievements,
        'totalPoints': userProgress.value.totalPoints,
        'lastStudyDate': userProgress.value.lastStudyDate.toIso8601String(),
      };
      await prefs.setString('user_progress', jsonEncode(progressJson));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
  
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = prefs.getString('user_progress');
      
      if (progressString != null) {
        final progressJson = jsonDecode(progressString) as Map<String, dynamic>;
        userProgress.value = UserProgress(
          currentStreak: progressJson['currentStreak'] ?? 0,
          longestStreak: progressJson['longestStreak'] ?? 0,
          totalDaysStudied: progressJson['totalDaysStudied'] ?? 0,
          disciplineLevel: progressJson['disciplineLevel'] ?? 1,
          theologicalDepth: progressJson['theologicalDepth'] ?? 1,
          apologeticsLevel: progressJson['apologeticsLevel'] ?? 1,
          categoryProgress: Map<String, int>.from(progressJson['categoryProgress'] ?? {}),
          achievements: List<String>.from(progressJson['achievements'] ?? []),
          totalPoints: progressJson['totalPoints'] ?? 0,
          lastStudyDate: DateTime.parse(progressJson['lastStudyDate'] ?? DateTime.now().toIso8601String()),
        );
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  String getStreakMessage() {
    final streak = userProgress.value.currentStreak;
    if (streak == 0) return 'Start your journey today! 🌱';
    if (streak < 7) return '$streak day streak! Keep going! 🔥';
    if (streak < 30) return '$streak days strong! Amazing! ⭐';
    return '$streak days! You\'re unstoppable! 🏆';
  }
}