class UserProgress {
  final int currentStreak;
  final int longestStreak;
  final int totalDaysStudied;
  final int disciplineLevel;
  final int theologicalDepth;
  final int apologeticsLevel;
  final Map<String, int> categoryProgress;
  final List<String> achievements;
  final int totalPoints;
  final DateTime lastStudyDate;

  UserProgress({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDaysStudied,
    required this.disciplineLevel,
    required this.theologicalDepth,
    required this.apologeticsLevel,
    required this.categoryProgress,
    required this.achievements,
    required this.totalPoints,
    required this.lastStudyDate,
  });

  factory UserProgress.initial() {
    return UserProgress(
      currentStreak: 0,
      longestStreak: 0,
      totalDaysStudied: 0,
      disciplineLevel: 1,
      theologicalDepth: 1,
      apologeticsLevel: 1,
      categoryProgress: {
        'soteriology': 0,
        'bibliology': 0,
        'hamartiology': 0,
        'pneumatology': 0,
        'christology': 0,
        'eschatology': 0,
      },
      achievements: [],
      totalPoints: 0,
      lastStudyDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  UserProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalDaysStudied,
    int? disciplineLevel,
    int? theologicalDepth,
    int? apologeticsLevel,
    Map<String, int>? categoryProgress,
    List<String>? achievements,
    int? totalPoints,
    DateTime? lastStudyDate,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDaysStudied: totalDaysStudied ?? this.totalDaysStudied,
      disciplineLevel: disciplineLevel ?? this.disciplineLevel,
      theologicalDepth: theologicalDepth ?? this.theologicalDepth,
      apologeticsLevel: apologeticsLevel ?? this.apologeticsLevel,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      achievements: achievements ?? this.achievements,
      totalPoints: totalPoints ?? this.totalPoints,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}